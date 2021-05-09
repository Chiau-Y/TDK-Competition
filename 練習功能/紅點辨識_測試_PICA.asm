list p=18f4520
#include <p18f4520.inc>
CONFIG OSC=HS, PWRT=ON, WDT=OFF, LVP=OFF,PBADEN=OFF,CCP2MX=PORTBE

COUNT_R     equ 0x30
COUNT_L     equ 0x31
COUNT_C     equ 0x32
COUNT_INT   equ 0x33
COUNT_FRONT equ 0x34
COUNT_BACK  equ 0x35
HIT_NUMBER  equ 0x36
INT_FLAG    equ 0x37

org 0x00
    GOTO INITIAL
;-------------high priority interrupt program----------
org 0x08
    NOP
    GOTO JUDGE_FRONT
;----------------Initial program start-----------------
org 0x40
INITIAL:
    CALL INITIAL_1
    CALL INITIAL_2
    CALL INITIAL_INT
    GOTO LOOP_1
;----------Main program (Counting red points)----------
LOOP_1:
    TSTFSZ PORTB,0
    GOTO LOOP_1
    GOTO LOOP_INT
LOOP_INT:
    BSF LATA,4    
    NOP
    BTFSS INT_FLAG,0
    BRA $-4
    INCF COUNT_FRONT
    CLRF INT_FLAG
    GOTO LOOP_1
;------------------Subroutine (interrrupt)-------------
JUDGE_FRONT:
    BCF LATA,4
    BCF INTCON3,INT1IF
F_1:
    MOVLW B'00000001'
    CPFSEQ COUNT_FRONT
    GOTO F_2
    GOTO ACTION_1
F_2:
    MOVLW B'00000010'
    CPFSEQ COUNT_FRONT
    GOTO F_3
    GOTO ACTION_2
F_3:
    MOVLW B'00000011'
    CPFSEQ COUNT_FRONT
    GOTO F_0
    GOTO ACTION_3
F_0:
    SETF INT_FLAG
    NOP
    RETFIE

ACTION_1:           
    MOVLW B'11110000'
    MOVWF LATD
    SETF INT_FLAG
    RETFIE
ACTION_2:           
    MOVLW B'10101010'
    MOVWF LATD
    SETF INT_FLAG
    RETFIE
ACTION_3:           
    MOVLW B'00010001'
    MOVWF LATD
    SETF INT_FLAG
    CLRF COUNT_FRONT
    RETFIE
;--------------------Initial Setting--------------------   
INITIAL_1:
    CLRF TRISD
    MOVLW B'10000000'
    MOVWF LATD
    BCF TRISA,4
    BCF LATA,4
    BSF TRISB,0
    BSF TRISB,1
    RETURN
INITIAL_2:
    CLRF COUNT_C
    CLRF COUNT_R
    CLRF COUNT_L
    CLRF COUNT_INT
    CLRF HIT_NUMBER
    CLRF INT_FLAG  
    MOVLW B'00000001'
    MOVWF COUNT_FRONT
    RETURN
INITIAL_INT:
    BSF RCON,IPEN
    BSF INTCON,GIEH
    BSF INTCON,GIEL
    BCF INTCON3,INT1IF
    BSF INTCON2,INTEDG1 
    BSF INTCON3,INT1IP
    BSF INTCON3,INT1IE
    RETURN
;---------------------Program End-----------------------
END
