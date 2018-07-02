Readme:

0) APDUs die man für die unten gegebene Testbench zur Karte schicken muss => siehe APDUs.txt (genau in dieser Reihenfolge)





1) Davon ausgehen, dass Register belegt sein können. (Simulator hat im Register Wert 0 muss nicht heissen bei Kartenbetrieb auch null)
   Vorallem ist im Simulator das dort definierte "NULL" Register mit Werten vorbelegt.

2) RAM Zellen bestimmter Variablen sollten geleert werden. (z.B. crtResult3).

3) Sonst kommt es gegebenfalls,  z.B. zu "gepaddeten" 01 Bytes, bei den Zwischenergebnissen. => Falsche Berechnung

4) Operatorlänge ist derzeit fest verankert im Program (RSA.S) 0x08 

5) Der Trigger Pin für die Smartcard wird gesetzt (genau am Anfang der Berechnung) und wird nach der Berechnung wieder gelöscht
   Somit lässt sich der Bereich genau eingrenzen, welcher Stromverbrauch von was wo liegt.
   Falls der Trigger an einer anderen Position gewünscht, einfach in der RSA.S die folgenden Zeilen Code 
  (aktuell direkt hinter der Sprunkmarke "computeResult" an die gewüschte Position bringen:
  
 				SBI 0x17, 5
				SBI 0x17, 7
				SBI 0x18, 5
				SBI 0x18, 7

6) Im Datasegment funktioniert es nicht! wie Simulator, dass man z.B. 16 Bytes im RAM auf einmal erstelen kann.
   Deshalb der Workaround (siehe ganz unten im RSA.S Code).

7) Simulatorfähige "simulation_xmega256.asm" Datei für den xmega256 mit Testbench vorbelegt ganz unten

8) Simulatorfähige "simulation_atmega163.asm" Datei für die Atmega163 Smartcard mit Testbench vorbelegt ganz unten


 
Eine Testbench für RSA Faul Injection (speziell für diese Implementierung, falls Debug Zwecks notwendig):
		
		Testbench
		
		---------------------------
		x = 7AF59B507AF59B5
		e = D48A7016BE9B105
		d = 1575AD9C07AF59B5
		n = F003C276B0FD6DD
		phi(n) = F003C26EF075DDC
		sig = x^d mod n = 5BB21F18BBDC58B
		---------------------------
		p = 3B9ACA07
		pInv = 32EC6240
		p-1 = 3B9ACA06
		q = 406DAEFB
		qInv = C7E72FA
		q-1 = 406DAEFA
		---------------------------
		xp = x mod p = 15D73732
		xq = x mod q  = EA0282E
		yp = xp^dp mod p = F71B238
		---------------------------
		dp = d mod p -1 = 1AC449D3
		dq = d mod q -1 = 29FE47C7
		yq = xq^dq mod q = 3E6B5E3A
		---------------------------
		yp * q = 3E30A854D73CCE8
		yq * p = E887C907A2D5796
		t1 = yp * q * qInv = 308FFC53A52F44EE856A90
		t2 = yq * p * pInv = 2E413BAEEDBEFCBF1255180
		t1 + t2 = 314A3B742811F10DFAABC10
		crt_sig = t1 + t2 mod n = 5BB21F18BBDC58B
