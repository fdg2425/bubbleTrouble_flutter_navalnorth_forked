$projectName = "navalnorth_branch_gs_ideas"
flutter build web --base-href /webtest/bubble/${projectName}/
Set-PSDebug -Trace 1
Remove-Item -Path "..\webtest\bubble/${projectName}" -Recurse -Force 
Copy-Item -Path "build\web" -Destination "..\webtest\bubble/${projectName}" -Recurse 
Set-PSDebug -Off