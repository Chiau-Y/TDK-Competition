list p=18f4520
#include <p18f4520.inc>
CONFIG OSC=HS, PWRT=ON, WDT=OFF, LVP=OFF,PBADEN=OFF,CCP2MX=PORTBE
#define duty_80 B'01111100'
#define duty_72 B'01101111'
#define duty_70 B'01101100'
#define duty_68 B'01101001'
#define duty_66 B'01100110'
#define duty_64 B'01100011'
#define duty_62 B'01100000'
#define duty_60 B'01011101'
#define duty_58 B'01011001'
#define duty_56 B'01010110'
#define duty_54 B'01010011'
#define duty_52 B'01010000'
#define duty_50 B'01001101'
#define duty_48 B'01001010'
#define duty_46 B'01000111'
#define duty_44 B'01000100'
#define duty_42 B'01000001'
#define duty_40 B'00111110'
#define duty_38 B'00111010'
COUNT_R equ 0x30
COUNT_L equ 0x31
COUNT_C equ 0x32

org 0x00
    GOTO INITIAL
;-------------------Initial program start--------------
org 0x40
INITIAL:
    CALL INIT_CCP
    CALL INITIAL_2
    SETF TRISD
    BCF TRISB,4
    BCF TRISB,5
    BCF TRISB,6
    BCF TRISB,7
    GOTO LOOP
;-------------------Main program (traction)------------
LOOP:
    CLRF COUNT_R
    CLRF COUNT_L
    CLRF COUNT_C
    BTFSC PORTD,6
    CALL INCREASE_1
    BTFSC PORTD,5
    INCF COUNT_R
    BTFSC PORTD,2
    INCF COUNT_L
    BTFSC PORTD,1
    CALL INCREASE_2
JUDGE_1:
    MOVF COUNT_L,0
    SUBWF COUNT_R,0
    MOVWF COUNT_C
    BTFSC STATUS,2
    GOTO SPEED_ZERO
    BTFSC STATUS,4
    GOTO NEGATIVE
    GOTO POSITIVE

SPEED_ZERO:
    CALL FORWARD
    MOVLW duty_60
    MOVWF CCPR1L
    MOVWF CCPR2L
    GOTO LOOP
POSITIVE:
R1:
    MOVLW B'00000001'
    CPFSEQ COUNT_C
    GOTO R2
    GOTO SPEED_ZERO
R2:
    MOVLW B'00000010'
    CPFSEQ COUNT_C
    GOTO R3
    CALL SELF_CW
    MOVLW duty_72
    MOVWF CCPR1L
    MOVLW duty_48
    MOVWF CCPR2L
    GOTO LOOP
R3:
    MOVLW B'00000011'
    CPFSEQ COUNT_C
    GOTO SPEED_ZERO
    CALL SELF_CW
    MOVLW duty_66
    MOVWF CCPR1L
    MOVLW duty_54
    MOVWF CCPR2L
    GOTO LOOP
NEGATIVE:
NEGF COUNT_C
L1:
    MOVLW B'00000001'
    CPFSEQ COUNT_C
    GOTO L2
    GOTO SPEED_ZERO
L2:
    MOVLW B'00000010'
    CPFSEQ COUNT_C
    GOTO L3
    CALL SELF_CCW
    MOVLW duty_48
    MOVWF CCPR1L
    MOVLW duty_72
    MOVWF CCPR2L
    GOTO LOOP
L3:
    MOVLW B'00000011'
    CPFSEQ COUNT_C
    GOTO SPEED_ZERO
    CALL SELF_CCW
    MOVLW duty_54
    MOVWF CCPR1L
    MOVLW duty_66
    MOVWF CCPR2L
    GOTO LOOP
;-----------------------Setting------------------------
INIT_CCP:
    MOVLW 0x9B
    MOVWF PR2
    BCF TRISC,2
    BCF TRISB,3
    MOVLW B'00001100'
    MOVWF CCP1CON
    MOVWF CCP2CON
    MOVLW B'00000101'
    MOVWF T2CON
    RETURN

INITIAL_2:
    CLRF COUNT_C
    CLRF COUNT_R
    CLRF COUNT_L
    RETURN
;------------------Direction of pwm-------------------
FORWARD:
    BCF LATB,4
    BSF LATB,5
    BCF LATB,6
    BSF LATB,7
    RETURN
BACKWARD:
    BSF LATB,4
    BCF LATB,5
    BSF LATB,6
    BCF LATB,7
    RETURN
SELF_CW:
    BCF LATB,4
    BSF LATB,5
    BSF LATB,6
    BCF LATB,7
    RETURN
SELF_CCW:
    BSF LATB,4
    BCF LATB,5
    BCF LATB,6
    BSF LATB,7
    RETURN
;------------------Subroutine (traction)-------------
INCREASE_1:
    INCF COUNT_R
    INCF COUNT_R
    RETURN
INCREASE_2:
    INCF COUNT_L
    INCF COUNT_L
    RETURN

END
