-- Footnote droplet (v003)
-- Bundled shell: Contents/Resources/Footnote.sh (no absolute mother-ship path)
-- Output: basename_ai.ext
on resolveFootnoteSh()
	set appPath to POSIX path of (path to me)
	return appPath & "Contents/Resources/Footnote.sh"
end resolveFootnoteSh

on open theItems
	set shPath to my resolveFootnoteSh()
	set sh to "/bin/zsh " & quoted form of shPath
	repeat with f in theItems
		set sh to sh & " " & quoted form of POSIX path of f
	end repeat
	try
		set res to do shell script sh
		display notification res with title "Footnote" sound name "Glass"
	on error errMsg
		display dialog "Footnote error: " & errMsg buttons {"OK"} default button 1 with icon stop
	end try
end open

on run
	display dialog "Drop PNG/JPEG images onto this icon. Creates basename_ai copies with C2PA AI provenance (for honest disclosure on X)." buttons {"OK"} default button 1
end run
