Config { 
    font = "xft:Droid Sans Mono:size=8:bold:antialias=true"
    alpha = 200,
    bgColor = "#000000",
    fgColor = "#ffffff",
  --  position = Static { xpos = 1, ypos = 1, width = 2435, height = 15 },
    position = TopW L 100,
	lowerOnStart = True,
    allDesktops =      False,
    commands = [
         --Run Weather "UUDD" ["-t","<station>: <tempC>C","-L","18","-H","25","--normal","green","--high","red","--low","lightblue"] 36000
	     Run Weather "UUDD" ["-t","<tempC>°C","-L","18","-H","25","--normal","green","--high","red","--low","lightblue"] 36000
        ,Run Memory ["-t","<used>/<total>M (<cache>M)","-H","8192","-L","4096","-h","#FFB6B0","-l","#CEFFAC","-n","#FFFFCC"] 10        
        ,Run Date "%Y.%m.%d %H:%M:%S" "date" 10
        ,Run CoreTemp [ "--template" , "<core0> <core1> <core2> <core3> <core4>°C"
            , "--Low"      , "70"        -- units: °C
            , "--High"     , "80"        -- units: °C
            , "--low"      , "#508488"
            , "--normal"   , "#307185"
            , "--high"     , "#5F2940"
        ] 50
        ,Run StdinReader
    ],
    sepChar = "%",
    alignSep = "}{",
    template = "%StdinReader% }{ %coretemp% | %memory% | %UUDD% | <fc=#BDC0DF>%date%</fc>   "
}
