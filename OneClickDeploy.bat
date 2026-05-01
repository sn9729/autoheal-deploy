@echo off
color 0B
echo =======================================================
echo      AUTOHEAL DEPLOYMENT - ONE CLICK AUTOMATION
echo =======================================================
echo.
echo [1/4] Connecting to AWS and Provisioning Infrastructure...
cd terraform
set TFVARS=terraform.tfvars
findstr /i /r /c:"^mongo_uri *= *\"*REPLACE_ME\"*$" "%TFVARS%" >nul
if not errorlevel 1 goto MONGO_MISSING
findstr /i /r /c:"^session_secret *= *\"*REPLACE_ME\"*$" "%TFVARS%" >nul
if not errorlevel 1 goto SECRET_MISSING
goto TF_OK

:MONGO_MISSING
echo [!] Please update terraform.tfvars with your MongoDB Atlas URI (mongo_uri).
pause
exit /b 1

:SECRET_MISSING
echo [!] Please update terraform.tfvars with your session secret (session_secret).
pause
exit /b 1

:TF_OK
call terraform init
set APPLY_REQUIRED=1
if exist terraform.tfstate (
    call terraform state show -no-color aws_instance.app_server >nul 2>&1
    if not errorlevel 1 set APPLY_REQUIRED=0
)

if "%APPLY_REQUIRED%"=="1" (
    call terraform apply -auto-approve
) else (
    echo [!] Existing EC2 instance found in Terraform state. Skipping apply to avoid replacement.
    call terraform apply -refresh-only -auto-approve
)

echo.
echo [2/4] Fetching Server IP Address...
FOR /F "tokens=* USEBACKQ" %%F IN (`terraform output -raw ec2_public_ip`) DO (
    SET EC2_IP=%%F
)

echo.
echo [+] AWS EC2 Instance Created Successfully! IP: %EC2_IP%
echo.
echo [3/4] Automating Jenkins, Docker, and App Installation...
echo Jenkins and the app will open now. If they are still starting, refresh after a minute.

echo.
echo [4/4] Opening Jenkins and Application in your web browser...
start http://%EC2_IP%:8080
start http://%EC2_IP%:3000

echo.
echo =======================================================
echo      DEPLOYMENT COMPLETE! 
echo =======================================================
echo You can now show the Jenkins pipeline and the live app to your sir!
pause
