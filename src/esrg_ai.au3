#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Change2CUI=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;   esurge1.au3 - automates running program E-Surge

$dlay=600
AutoItSetOption("SendKeyDelay",40)
AutoItSetOption("MouseCoordMode",0)

$x=ProcessList("esrg_ai.exe")
if $x[0][0]>1 Then
	ConsoleWrite("esrg_ai allready running... exiting." & @CRLF)
	Exit
EndIf

if $CmdLine[0]<1 Then
	ConsoleWrite("")
	ConsoleWrite("usage: esurge4 open rname=result_filename dname=data_filename ng=ngrps ni=nicov ns=nstates ne=nevents na=nage" & @CRLF)
	ConsoleWrite("usage: esurge4 run is=init_state tr=trans [t2=trans2] ev=event CI=[yes or no] [ivt=s1] [ive=s2]" & @CRLF)
	ConsoleWrite("usage: esurge4 getIVFV" & @CRLF)
	ConsoleWrite("usage: esurge4 close" & @CRLF)
	ConsoleWrite("defaults: is=i tr=from.to ev=firste+nexte CI=no ng=1 ni=0 ns=2 ne=2 na=1" & @CRLF)
	Exit
EndIf

$init_state="i"
$trans="from.to"
$trans2=""
$event="firste+nexte"
$computeCI="no"
$projname="dipper.mod"
$dataname="dipper.inp"
$ngrps=1
$nicov=0
$nstates=2
$nevents=2
$nage=1
$factopt=""
$slow=40
$ivi=""
$ivt=""
$ive=""
$verb=0
$suff=""
$esurge=""
Global $scut[99][3]
$nscuts=0
for $i=1 to $CmdLine[0]
	if $verb>0 Then
		ConsoleWrite(">" & $CmdLine[$i] & @CRLF)
	EndIf
	$s=StringSplit($CmdLine[$i],"=")
	Select
	Case $s[1]=="esrg"
		$esurge=$s[2]
	Case $s[1]=="is"
		$init_state=$s[2]
	Case $s[1]=="tr"
		$trans=$s[2]
	Case $s[1]=="t2"
		$trans2=$s[2]
	Case $s[1]=="ev"
		$event=$s[2]
	Case $s[1]=="CI"
		$computeCI=$s[2]
	Case $s[1]=="rname"
		$projname=$s[2]
	Case $s[1]=="dname"
		$dataname=$s[2]
	Case $s[1]=="ng"
		$ngrps=$s[2]
	Case $s[1]=="ni"
		$nicov=$s[2]
	Case $s[1]=="ns"
		$nstates=$s[2]
	Case $s[1]=="ne"
		$nevents=$s[2]
	Case $s[1]=="na"
		$nage=$s[2]
	Case $s[1]=="factopt"
		$factopt=$s[2]
	Case $s[1]=="slow"
		$slow=$s[2]
	Case $s[1]=="dlay"
		$dlay=$s[2]
	Case $s[1]=="ivt"
		$ivt=$s[2]
	Case $s[1]=="ive"
		$ive=$s[2]
	Case $s[1]=="verb"
		$verb=1
	Case $s[1]=="suff"
		$suff=$s[2]
		For $j=3 to $s[0]
			$suff=$suff & "=" & $s[$j]
		Next
	Case Else
		if $i>1 Then
			ConsoleWrite("i=" & $i & " unknown option:" & $s[1] & @CRLF)
		EndIf
	EndSelect
Next
AutoItSetOption("SendKeyDelay",$slow)

if $CmdLine[1]="close" Then
	if WinExists("E-SURGE V","") Then
		sleep($dlay)
		WinSetState("E-SURGE V","",@SW_RESTORE)
		Sleep($dlay);
		WinActivate("E-SURGE V")
		Sleep($dlay)
		Send("^s")           ;  save models
		Sleep($dlay)
		send("{F10}{ENTER}{DOWN 5}{ENTER}")        ;   quit program E-SURGE
	Else
		ConsoleWrite("E-SURGE window doesn't exist")
	EndIf
	Sleep($dlay)
	if WinExists("E-SURGE question") Then
		send("{Enter}")
		Sleep($dlay)
	EndIf
	if WinExists("file name to store") Then
		WinActivate("file name to store")
		send("{TAB 4}{Enter}")
		Sleep($dlay)
	EndIf
	WinClose("E-SURGE V")
	ConsoleWrite("exit program" & @CRLF)
	Exit
EndIf

if $CmdLine[1]="run" Then
	$datadir=@WorkingDir
	$shortcut_file="shortcuts.out"
	$modname="pi(" & $init_state & ")phi(" & $trans & ")p(" & $event & ")"
	if $trans2>"" Then
		$modname="pi(" & $init_state & ")S(" & $trans & ")psi(" & $trans2 & ")p(" & $event & ")"
	EndIf
	if $init_state=="i" Then
		$modname=StringReplace($modname,"pi(i)","")
	EndIf
	$modname=$modname & $suff
	ConsoleWrite("modname=" & $modname & @CRLF)
	AutoItSetOption("PixelCoordMode",0)
	$w=WinActivate("E-SURGE V","")
	if $w=0 then
		ConsoleWrite("E-SURGE window not active... run esrg_open(...)")
		Exit
	EndIf
	WinSetState("E-SURGE V","",@SW_RESTORE)
	Sleep($dlay);
	;  check for shortcuts in result file
	$x=FileRead($projname)
	$y=StringSplit($x,@LF)
	if $y[0]>3 Then
		$nmods=Number($y[3])
		$nscuts=Number($y[4+$nmods*7])
		if $verb>0 Then
			ConsoleWrite("nmods=" & $nmods & " nscuts=" & $nscuts & @CRLF)
		EndIf
		if $nscuts>0 Then
			For $i=1 to $nscuts
				$z=StringSplit(StringReplace($y[4+7*$nmods+$i],"  "," ")," ")
				$scut[$i][1]=$z[1]
				$scut[$i][2]=$z[2]
				if $verb>0 Then
					ConsoleWrite($i & ")z=" & $z[1] & "," & $z[2] & " scut=" & $scut[$i][1] & "=" & $scut[$i][2] & @CRLF)
				EndIf
			Next
		EndIf
	EndIf
	If FileExists($datadir & "\" & $shortcut_file) Then
		shortcuts()
	EndIf
	gepat()
	gemaco()
	IVFV()
	if $verb>0 Then
		consolewrite("computeCI=" & $computeCI & @CRLF)
	EndIf
	If $computeCI>="yes" Then
		check_computeCI()
		sleep(3000)
	EndIf
	xrun()
	WinWaitActive("E-SURGE V")
	sleep($dlay)
	send("^s")        ;  save results file
	WinSetState("E-SURGE V","",@SW_MINIMIZE)
	ConsoleWrite("esrg_ai done!" & @CRLF)
EndIf

if $CmdLine[1]="open" Then
	if WinExists("E-SURGE V") then
		ConsoleWrite("E-SURGE window already open... quitting" & @CRLF)
		exit
	endif
    if not FileExists($dataname) Then
	    ConsoleWrite($dataname & "NOT FOUND... abort!" & @CRLF)
	    Exit
    EndIf
	$s=StringSplit($projname,"\")
	$datadir=@WorkingDir
	if $s[0]<2 Then
		$projname=$datadir & "\" & $projname
	EndIf
	ConsoleWrite("working dir:" & $datadir & @CRLF)
	If $esurge="" Then
		FileChangeDir("c:\progra~1");   look for esurge.exe
		$a=FileFindFirstFile("E-SUR*")
		$b=FileFindNextFile($a)
		FileChangeDir("c:\progra~1\" & $b)
		$a=FileFindFirstFile("E_SUR*")
		$c=FileFindNextFile($a)
		$esurge="c:\progra~1\" & $b & "\" & $c
	EndIf
	if not FileExists($esurge) Then
		ConsoleWrite("Failed to launch... E-SURGE - not found" & @CRLF)
		Exit
	EndIf
	$env=EnvGet("PATH")
	$env=$env & ";c:\progra~1\matlab\matlab~1\v901\runtime\win64"
	EnvSet("PATH",$env)
	ConsoleWrite(">>>>" & $esurge & @CRLF & "working dir=" & @WorkingDir & @CRLF)
	Run($esurge)
	$i=WinWaitActive("E-SURGE V")
	Sleep($dlay);
	if FileExists($projname) Then
		oldproj()
	else
		newproj()
		datainp()
	EndIf
	;WinWaitActive("Is there external","",2)
	sleep($dlay)
	if WinExists("Is there external") Then
		if $verb>0 Then
			ConsoleWrite("Window 'Is there external' exists." & @CRLF)
		EndIf
		WinActivate("Is there external")
		sleep($dlay)
		send("{TAB}{ENTER}")
		sleep($dlay)
	EndIf

	if $verb>0 Then
		ConsoleWrite("modify ngrps,nicov,nstates,nevents,nage" & @CRLF)
	EndIf
	MouseClick("left",400,200)
	WinWaitActive("Change")
	sleep($dlay)
	send($ngrps & "{TAB}" & $nicov & "{TAB}" & $nstates & "{TAB}" & $nevents & "{TAB}" & $nage & "{TAB}{ENTER}")
	sleep($dlay)
	If $factopt=="noinit" Then
		if $verb>0 Then
			ConsoleWrite("send models>>if any fact>>trans&enc option" & @CRLF)
		EndIf
		sleep($dlay)
		send("{F10}{RIGHT 2}{DOWN}{RIGHT}{DOWN}{ENTER}") ; Models/If any factorization/transition and encounter
		sleep($dlay)
	EndIf
	If $factopt=="occupancy" Then
		if $verb>0 Then
			ConsoleWrite("send models>>Markovian States>>occupancy option" & @CRLF)
		EndIf
		sleep($dlay)
		send("{F10}{RIGHT 2}{DOWN 2}{RIGHT}{DOWN 2}{ENTER}") ; Models/If any factorization/transition and encounter
		sleep($dlay)
	EndIf
	WinSetState ( "E-SURGE V", "", @SW_MINIMIZE )
	ConsoleWrite("esrg_ai done!" & @CRLF)
EndIf

Func newproj()
	if $verb>0 Then
		ConsoleWrite("delete " & $projname & @CRLF)
	EndIf
	ConsoleWrite("New project..." & @CRLF)
	fileDelete($projname)
	send("^n")
	WinWaitActive("file name to store")
	sleep($dlay)
	send($projname & "{ENTER}")
	sleep($dlay)
EndFunc

Func oldproj()
   send("^o")
   if $verb>0 Then
	   ConsoleWrite("wait for 'old file name'" & @CRLF)
   EndIf
   ConsoleWrite("Open old project..." & @CRLF)
   WinWaitActive("old file name")
   sleep($dlay)
   send($projname & "{ENTER}")
   sleep($dlay)
EndFunc

Func datainp()
   if StringLower(StringRight($dataname,4))==".inp" Then
	   	consolewrite("mark input file..." & @CRLF)
		send("^m")
   Else
	   consolewrite("biomeco input file..." & @CRLF)
	   send("^b")
   EndIf
   sleep($dlay)
   send($dataname & "{ENTER}")
   sleep($dlay)
EndFunc

Func mod_nage()
	if $verb>0 Then
		ConsoleWrite("mod_nage" & @CRLF)
	EndIf
	MouseClick("left",400,200)
	WinWaitActive("Change")
	sleep($dlay)
	send($ngrps & "{TAB}" & $nicov & "{TAB}" & $nstates & "{TAB}" & $nevents & "{TAB}" & $nage & "{TAB}{ENTER}")
EndFunc

Func check_computeCI()
	WinActivate("E-SURGE V")
	Winmove("E-SURGE V","",0,0)
	$x1=333           ; x offset for mouseclick
	$y1=357
	$x2=415           ; x offset for pixelGetColor ... coord mode 0 doesn't work
	$y2=445
	$chk=hex(PixelGetColor($x2+4,$y2+8))
	if $chk<>"00202020" then
		mouseclick("left",$x1+3,$y1+3)
	endif
EndFunc

Func shortcuts()
	WinWaitActive("E-SURGE V")
	sleep($dlay)
	MouseClick("left",450,525)  ;  click shortcut button
	WinWaitActive("interface_shortcut")
	sleep($dlay)
	MouseClick("left",60,40)    ;  click 1st menu (I forget the name)
	MouseClick("left",60,66)    ;   click 'load shortcut file from disk' menu
	;send("{F10}{DOWN}{ENTER}")
	sleep($dlay)
	WinWaitActive(" Load")
	sleep($dlay)
	if $verb>0 Then
		ConsoleWrite("send shortcuts file" & @CRLF)
	EndIf
	send($shortcut_file & @CRLF)
	sleep($dlay)
	MouseClick("left",600,444)
	WinWaitActive("interface_shortcut")
	sleep($dlay)
	send("{F10}{DOWN 4}{ENTER}")
	sleep($dlay)
	$x=FileRead($shortcut_file)
	$y=StringSplit($x,@LF)
	$nscuts=Number($y[1])
	if $verb>0 Then
		ConsoleWrite("shortcuts (" & $y[0] & " lines read)" & @CRLF & "y(2)=" & $y[2] & @CRLF)
		ConsoleWrite("number of shortcuts:" & $nscuts & @CRLF)
	EndIf
	For $i=1 to $nscuts
		$z=StringSplit($y[Number($i)+1]," ")
		$scut[$i][1]=$z[1]
		$scut[$i][2]=$z[2]
		if $verb>0 Then
			ConsoleWrite($i & ")" & $scut[$i][1] & "=" & $scut[$i][2] & @CRLF)
		EndIf
	Next
EndFunc

Func gepat()
	send("^p") ; Gepat interface   ...   just take defaults and exit
	if $verb>0 Then
		ConsoleWrite("wait for gepat window" & @CRLF)
	EndIf
	WinWaitActive("Gepat")
	if FileExists("trans.pat") Then
		SLEEP($dlay)
		send("{F10}{RIGHT 2}{ENTER}{DOWN}{ENTER}")  ;  menu - Input-Output for patterns/load file with patterns
		if $verb>0 Then
			ConsoleWrite("waiting for Load file for patterns window" & @CRLF)
		EndIf
		WinWaitActive(" Load file for patterns")
		sleep($dlay)
		send("trans.pat{ENTER}")
	EndIf
	sleep($dlay)
	send("^q") ; exit Gepat
	sleep($dlay)
EndFunc

Func gemaco()
	send("^g") ; Gemaco interface
	if $verb>0 Then
		ConsoleWrite("wait for gemaco window" & @CRLF)
	EndIf
	WinWaitActive("Gemaco interface")
	SLEEP($dlay)
	send("{TAB 4}^a" & $init_state & "^{ENTER}")
	$tt=StringReplace($trans,"+","{+}")
	if $verb>0 Then
		ConsoleWrite("trans=" & $trans & " tt=" & $tt & " trans2=" & $trans2 & @CRLF)
	EndIf
	send("{F10}{ENTER}{RIGHT}{DOWN 2}{ENTER}")
	sleep($dlay)
	$do_cov=0    ;   check if trans model expr is in shortcuts...
	For $i=1 to $nscuts
		if $trans==$scut[$i][1] Then
			if StringInStr($scut[$i][2],"*x(") Then
				$do_cov=1
			EndIf
		EndIf
	Next
	if StringInStr($trans,"*x(") or $do_cov>0 Then
		sleep($dlay)
		MouseClick("left",400,550) ;  click on "No external variables"
		sleep($dlay)
		MouseClick("left",400,590)  ;  click on "File with external variables"
		if $verb>0 Then
			ConsoleWrite("waiting for File to define" & @CRLF)
		EndIf
		WinWaitActive(" File to define","",5)
		Sleep($dlay)
		send("x.txt{ENTER}")
		Sleep($dlay)
		WinWaitActive("Gemaco int")
		MouseClick("left",500,380)
	EndIf
	send("^a" & $tt & "^{ENTER}")
	if $trans2>"" Then
		sleep($dlay)
		MouseClick("left",614,115) ;  click on ">>" to change step number
		sleep($dlay)
		MouseClick("left",500,380)  ;  click on expression input box
		$t2=StringReplace($trans2,"+","{+}")
		send("^a" & $t2 & "^{ENTER}")
	EndIf
	sleep($dlay)
	$e2=StringReplace($event,"+","{+}")
	send("{F10}{ENTER}{RIGHT}{DOWN 3}{ENTER}")
	sleep($dlay)
	send("^a" & $e2 & "^{ENTER}")
	SLEEP($dlay)
	send("^g")
	sleep($dlay)
	if WinExists("Shortcut analysis") Then
		ConsoleWrite("E-SURGE error: Model not well defined" & @CRLF)
		Exit
	EndIf
	send("^q") ; exit gemaco
	sleep($dlay)
	if WinExists("E-SURGE warning") Then
		ConsoleWrite("E-SURGE warning: Constrained Matrix not well defined" & @CRLF)
		Exit
	EndIf
EndFunc

Func IVFV()
	send("^i") ; IVFV interface
	if $verb>0 Then
		ConsoleWrite("wait for ivfv window" & @CRLF)
	EndIf
	WinWaitActive("Initial Value or")
	SLEEP($dlay)
	if $verb>0 Then
		ConsoleWrite("ivt=" & $ivt & " ive=" & $ive & @CRLF)
	EndIf
	If $ivt>"" Then
		send("{F10}{ENTER}{RIGHT}{DOWN 2}{ENTER}")   ;  menu /selected beta / transition
		do_init_vals($ivt)
	EndIf
	If $ive>"" Then
		send("{F10}{ENTER}{RIGHT}{DOWN 3}{ENTER}")   ;  menu /selected beta / transition
		do_init_vals($ive)
	EndIf
	Sleep($dlay)
	send("^q") ; exit IVFV
	sleep($dlay)
EndFunc

Func do_init_vals($ivals)
	Sleep($dlay)
	$s=StringSplit($ivals,",")
	if $verb>0 Then
		ConsoleWrite("#s=" & $s[0] & " s1=" & $s[1] & @CRLF)
	EndIf
	For $i=1 to $s[0]
		$t=StringSplit($s[$i],":")
		$n=$t[1]
		if $verb>0 Then
			ConsoleWrite(" n=" & $n & " t2=" & $t[2] & @CRLF)
		EndIf
		$cnt=0
		While $n>10
			MouseClick("left",350,620)
			$n=$n-10
			if $verb>0 Then
				ConsoleWrite("n=" & $n & @CRLF)
			EndIf
			$cnt=$cnt+1
		WEnd
		$y=(Number($n)-1)*34+270
		;ConsoleWrite("mouse move " & 385 & "," & $y & @CRLF)
		MouseClick("left",385,$y)
		;ConsoleWrite("mouse move " & 420 & "," & $y & @CRLF)
		MouseClick("left",420,$y)
		;ConsoleWrite("sending " & $t[2] & @CRLF)
		Send("^a" & $t[2])
		While $cnt>0
			MouseClick("left",115,620)
			$cnt=$cnt-1
		WEnd
	Next
	Sleep($dlay)
EndFunc

Func xrun()
	$fname=$modname & ".xls"
	if FileExists($fname) Then
		ConsoleWrite("deleting previous " & $fname & @CRLF)
		fileDelete($fname)
		fileDelete($modname & ".out")
	EndIf
	send("^r") ; Run
	if $verb>0 Then
		ConsoleWrite("wait for give model rank window" & @CRLF)
	EndIf
	WinWaitActive("Give model rank")
	SLEEP($dlay)
	;$v=StringReplace(StringReplace($modname,"+","P"),":","_")
	$m2=StringReplace(StringReplace(StringReplace($modname,"+","{+}"),":","-"),"*","X")
	send("{TAB}" & $m2 & "{TAB}{ENTER}")
	sleep($dlay)
	if $verb>0 Then
		ConsoleWrite("wait for draw estimates window" & @CRLF)
	EndIf
	WinWaitActive("Draw Estimates")
	sleep($dlay)
	WinClose("Draw Estimates")
EndFunc
