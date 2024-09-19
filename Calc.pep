         BR main
lf:      .ascii "\n---------\n\x00"
space:   .ascii " \x00"
eq:      .ascii " = \x00"
err:     .ascii "error\x00"


;check character for Q or q or a space
main:    LDBA charIn,d
         CPBA ' ',i
         BREQ main
         CPBA 'Q',i
         BREQ done
         CPBA 'q',i
         BREQ done
         
;store the sign and nummbers on the stack
         ADDSP -1,i
         STBA 0,s
 
         ADDSP -2,i
         DECI 0,s

         ADDSP -2,i
         DECI 0,s       
         
;check the sign by adding to A from stack and comparing
         
         CPBA '+',i
         BREQ add

         CPBA '-',i
         BREQ sub

         CPBA '*',i
         BREQ mult

         CPBA '/',i
         BREQ div


;do operation and store the value on the stack then branch to error or no error
add:     LDWA 2,s
         ADDA 0,s
         BRV error
         ADDSP -2,i
         STWA 0,s
         BR noError

sub:     LDWA 2,s
         SUBA 0,s
         BRV error
         ADDSP -2,i
         STWA 0,s
         BR noError

;find where to branch if both positive (fall through) or one negative
mult:    LDWA 2,s
         BRLT multFN
         LDWA 0,s
         BRLT multSN

;if both are positive
multP:   LDWX 2,s
         SUBX 1,i
         LDWA 0,s
loopP:   ADDA 0,s
         BRV error
         SUBX 1,i 
         BRLE prodP
         BR loopP    
prodP:   ADDSP -2,i
         STWA 0,s
         BR noError    

;if first one is negative check if second is negative and branch to multBN
multFN:  LDWA 0,s
         BRLT multBN
         LDWX 2,s
         NEGX
         SUBX 1,i
         LDWA 0,s
loopFN:  ADDA 0,s
         BRV error
         SUBX 1,i 
         BRLE prodFN
         BR loopFN    
prodFN:  NEGA 
         ADDSP -2,i
         STWA 0,s
         BR noError  

;if second on negative
multSN:  LDWX 2,s
         SUBX 1,i
         LDWA 0,s
loopSN:  ADDA 0,s
         BRV error
         SUBX 1,i 
         BRLE prodSN
         BR loopSN    
prodSN:  ADDSP -2,i
         STWA 0,s
         BR noError

;if both negative
multBN:  LDWX 2,s
         NEGX
         SUBX 1,i
         LDWA 0,s
loopBN:  ADDA 0,s 
         BRV error
         SUBX 1,i 
         BRLE prodBN
         BR loopBN    
prodBN:  NEGA
         ADDSP -2,i
         STWA 0,s
         BR noError

;find where to branch, if both positvie(fall through), if one negative branch
div:     LDWA 2,s
         BRLT divFN
         LDWA 0,s
         BRLT divSN

;if both are positive
divP:    LDWA 2,s
loopDP:  SUBA 0,s
         BRV error
         BRLT quotDP
         ADDX 1,i 
         BR loopDP    
quotDP:  ADDSP -2,i
         STWX 0,s
         BR noError   

;if first one is negative check if second is negative and branch to divBN
divFN:   LDWA 0,s
         BRLT divBN
         LDWA 2,s
loopDFN: ADDA 0,s 
         BRV error
         BRGT quotDFN
         ADDX 1,i 
         BR loopDFN    
quotDFN: NEGX
         ADDSP -2,i
         STWX 0,s
         BR noError 

;if only second one negative
divSN:   LDWA 2,s
loopDSN: ADDA 0,s 
         BRV error
         BRLT quotDSN
         ADDX 1,i 
         BR loopDSN    
quotDSN: NEGX
         ADDSP -2,i
         STWX 0,s
         BR noError

;if both negative
divBN:   LDWA 2,s
loopDBN: SUBA 0,s 
         BRV error
         BRGT quotDBN
         ADDX 1,i 
         BR loopDBN    
quotDBN: ADDSP -2,i
         STWX 0,s
         BR noError

;call subroutine to print and then branch to main and clear the stack
noError: CALL goodSub 
         ADDSP 7,i
         BR main


;call subroutine to print error and then branch to main and clear stack
error:   CALL badSub
         ADDSP 5,i
         BR main


         

;print the output if no overflow
goodSub: LDBA 0xFB8E,d
         STBA charOut,d
         STRO space,d
         DECO 0xFB8C,d
         STRO space,d
         DECO 0xFB8A,d
         STRO eq,d
         DECO 0xFB88,d
         STRO lf,d
         RET




;print error as output because of overflow
badSub:  LDBA 0xFB8E,d
         STBA charOut,d
         STRO space,d
         DECO 0xFB8C,d
         STRO space,d
         DECO 0xFB8A,d
         STRO eq,d
         STRO err,d
         STRO lf,d
         RET



;end program
done:    STOP        
         .end

