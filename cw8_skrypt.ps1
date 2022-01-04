#--------------CHANGELOG-------------#
# Automatyzacja przetwarzania danych #
#       autor: Dominika Szarek       #
#          data: 03.01.2022          #


$path= "C:\Users\cw8"
${TIMESTAMP}= Get-Date -Format "MM.dd.yyyy" 
$processed=-join ($path,"\PROCESSED")
$log=-join ($path,"\${TIMESTAMP}.log")
${NRINDEXU} = "402890"

function getDate{ #funkcja pobierająca date
    Get-Date -Format "MM.dd.yyyy HH:mm:ss"
}
$date=getDate

#Pobieranie danych
try {
$source = 'https://home.agh.edu.pl/~wsarlej/Customers_Nov2021.zip'
$destination = 'C:\Users\cw8\Customers_Nov2021.zip'
Invoke-RestMethod -Uri $source -OutFile $destination
Write-Output ($date + " - " + "Pobieranie danych" +" - "+"SUKCES") >> $log
}
catch{Write-Output ($date + " - " + "Pobieranie danych" +" - "+"BŁĄD") >> $log}


#Rozpakowanie danych za pomocą programu 7zip
try{
$7ZipPath = '"C:\Program Files\7-Zip\7z.exe"'
$zipFile = '"C:\Users\cw8\Customers_Nov2021.zip"'
$zipFilePassword = "agh"
$command = "& $7ZipPath e -oc:\Users\cw8 -y -tzip -p$zipFilePassword $zipFile"
iex $command

Write-Output ($date + " - " + "Rozpakowywanie danych" +" - "+"SUKCES") >> $log
}
catch{Write-Output ($date + " - " + "Rozpakowywanie danych" +" - "+"BŁĄD") >> $log}


#Filtracja danych
try{
$del=-join ($path,"\Customers_Nov2021.bad_${TIMESTAMP}.txt")

if (-not(Test-Path -Path $del -PathType Leaf)){New-Item -ItemType File -Path $del -Force -ErrorAction Stop}  
$csv1= Get-Content -Path (-join ( $path,"\Customers_old.csv"))
Get-Content -Path (-join ( $path,"\Customers_Nov2021.csv")) | Where-Object{$_ -ne ""}| Where-Object {$csv1 -notcontains $_} | Out-File -FilePath (-join ( $path,"\Customers_new.csv")) -Encoding utf8
$csv2= Get-Content -Path (-join ( $path,"\Customers_new.csv"))
Get-Content -Path (-join ( $path,"\Customers_Nov2021.csv")) | Where-Object{$_ -ne ""}| Where-Object {$csv2 -notcontains $_} | Out-File -FilePath $del #filtracja błędnych danych
Write-Output ($date + " - " + "Filtracja danych" +" - "+"SUKCES") >> $log
}
catch{Write-Output ($date + " - " + "Filtracja danych" +" - "+"BŁĄD") >> $log}

#drugie rozwiązanie
<#
$params = Import-Csv C:\Users\cw8\Customers_Nov2021.csv | Select-Object first_name, last_name, email, lat, long 
$paramsold = Import-Csv C:\Users\cw8\Customers_old.csv | Select-Object first_name, last_name, email, lat, long
$MyArrayList = [System.Collections.ArrayList]@();

for( $i=0; $i -lt $params.length; $i++) {
    for($j=0; $j -lt $paramsold.length; $j++) {
        if($params[$i].first_name + $_.last_name -eq $paramsold[$j].first_name + $_.last_name){ 
            break;
        } 
        if($j -eq $paramsold.length - 1) {
          $MyArrayList.Add($params[$i]);
        }
    }
}

$MyArrayList| Export-Csv -Path C:\Users\cw8\Customers_new.csv 
#>

#Utworzenie tabeli
try {
#
$MyServer = "localhost"
$MyPort  = "5432"
$MyDB = "postgres"
$MyUid = "postgres"
$MyPass = "$mypass"
$nrIndexu = "402890";

$DBConnectionString = "Driver={PostgreSQL UNICODE(x64)};Server=$MyServer;Port=$MyPort;Database=$MyDB;Uid=$MyUid;Pwd=$MyPass;" #łączenie z bazą danych 
$DBConn = New-Object System.Data.Odbc.OdbcConnection;
$DBConn.ConnectionString = $DBConnectionString;
$DBConn.Open();

$DBCmd3 = $DBConn.CreateCommand();
$DBCmd3.CommandText = "CREATE TABLE IF NOT EXISTS CUSTOMERS_$nrIndexu(first_name varchar(200), last_name varchar(200), email varchar(200), lat varchar(200), long varchar(200));"; #zapytanie-stworzenie tabeli
$rdr3 = $DBCmd3.ExecuteReader();
$tbl3 = New-Object Data.DataTable;
$tbl3.Load($rdr3);
$rdr3.Close();
$tbl3 | Format-Table -AutoSize

Write-Output ($date + " - " + "Tworzenie tabeli CUSTOMERS_402890" +" - "+"SUKCES") >> $log
}
catch{Write-Output ($date + " - " + "Tworzenie tabeli CUSTOMERS_402890" +" - "+"BŁĄD") >> $log}

#Import danych do tabeli 
try {
$DBConnectionString = "Driver={PostgreSQL UNICODE(x64)};Server=$MyServer;Port=$MyPort;Database=$MyDB;Uid=$MyUid;Pwd=$MyPass;"
$DBConn = New-Object System.Data.Odbc.OdbcConnection;
$DBConn.ConnectionString = $DBConnectionString;
$DBConn.Open();

$DBCmd3 = $DBConn.CreateCommand();
$DBCmd3.CommandText = "COPY CUSTOMERS_402890 FROM 'C:\Users\cw8\Customers_new.csv' DELIMITER ',' CSV HEADER;"; #zapytanie-import danych do tabeli
$rdr3 = $DBCmd3.ExecuteReader();
$tbl3 = New-Object Data.DataTable;
$tbl3.Load($rdr3);
$rdr3.Close();
$tbl3 | Format-Table -AutoSize
Write-Output ($date + " - " + "Import danych do tabeli" +" - "+"SUKCES") >> $log
}
catch{Write-Output ($date + " - " + "Import danych do tabeli" +" - "+"BŁĄD") >> $log}

#Przeniesienie pliku do podkatalogu
$processed=-join ($path,"\PROCESSED")

try{
if (-not(Test-Path -Path "$path\${TIMESTAMP}_Customers_new.csv" -PathType Leaf)){Rename-Item -Path "$path\Customers_new.csv" -NewName "${TIMESTAMP}_Customers_new.csv"}
 if (-not(Test-Path -Path "$path\PROCESSED\${TIMESTAMP}_Customers_new.csv" -PathType Leaf)){Move-Item "$path\${TIMESTAMP}_Customers_new.csv" -Destination "$path\PROCESSED"} 
Write-Output ($date + " - " + "Przenoszenie pliku do podkatalogu" +" - "+"SUKCES") >> $log
}catch{Write-Output ($date + " - " + "Przenoszenie pliku do podkatalogu" +" - "+"BŁĄD") >> $log}

#Wysłanie e-mail 
try{
$csv1= Get-Content -Path (-join ($path,"\Customers_old.csv"))
$csv2= Get-Content -Path (-join ($path,"\Customers_Nov2021.csv"))
$csv1len=$csv1.Length
$csv2len=$csv2.Length
$csv3=(Get-Content -Path (-join ($path,"\Customers_Nov2021.bad_${TIMESTAMP}.txt"))).Length

$DBConnectionString = "Driver={PostgreSQL UNICODE(x64)};Server=$MyServer;Port=$MyPort;Database=$MyDB;Uid=$MyUid;Pwd=$MyPass;"
$DBConn = New-Object System.Data.Odbc.OdbcConnection;
$DBConn.ConnectionString = $DBConnectionString;
$DBConn.Open();
$DBCmd3 = $DBConn.CreateCommand();
$DBCmd3.CommandText = "SELECT COUNT(*) FROM customers_402890";
$rdr3 = $DBCmd3.ExecuteReader();
$tbl3 = New-Object Data.DataTable;
$tbl3.Load($rdr3);
$tbl3
$rdr3.Close()
$row = $tbl3 | Select-Object -First 1 

function Send-ToEmail([string]$email){
    $emailSmtpServer = "mail"
    $emailSmtpServerPort = "587"
    $message = new-object Net.Mail.MailMessage
    $message.From = "raportcustomers@gmail.com"
    $message.To.Add($email)
    $message.Subject = "CUSTOMERS LOAD - ${TIMESTAMP}"
    $message.Body = "
                     •	liczba wierszy w pliku pobranym z internetu: $csv1len
                     •	liczba poprawnych wierszy (po czyszczeniu): $csv2len
                     •	liczba niepoprawnych rekordów: $csv3
                     •	ilość danych załadowanych do tabeli ${table}: $row     
    "
    $smtp = new-object Net.Mail.SmtpClient("smtp.gmail.com", "587")
    $smtp.EnableSSL = $true
    $smtp.Credentials = New-Object System.Net.NetworkCredential("raportcustomers@gmail.com", "$mypass")
    $smtp.send($message);
    write-host "Message 1 sent"
 }
Send-ToEmail -email "dominikaszx@gmail.com";
Write-Output ($date + " - " + "Wysłanie e-mail" +" - "+"SUKCES") >> $log
}catch{Write-Output ($date + " - " + "Wysłanie e-mail" +" - "+"BŁĄD") >> $log}

#Zastosowanie zapytania SQL
try{

$DBConnectionString = "Driver={PostgreSQL UNICODE(x64)};Server=$MyServer;Port=$MyPort;Database=$MyDB;Uid=$MyUid;Pwd=$MyPass;"
$DBConn = New-Object System.Data.Odbc.OdbcConnection;
$DBConn.ConnectionString = $DBConnectionString;
$DBConn.Open();
$DBCmd2 = $DBConn.CreateCommand();
$DBCmd2.CommandText = "CREATE TABLE IF NOT EXISTS BEST_CUSTOMERS_$nrIndexu(first_name char(200), last_name varchar(200), email varchar(200), lat varchar(200), long varchar(200));";
$rdr2 = $DBCmd2.ExecuteReader();
$tbl2 = New-Object Data.DataTable;
$tbl2.Load($rdr2);
$rdr2.Close();

$DBConnectionString2 = "Driver={PostgreSQL UNICODE(x64)};Server=$MyServer;Port=$MyPort;Database=$MyDB;Uid=$MyUid;Pwd=$MyPass;"
$DBConn2 = New-Object System.Data.Odbc.OdbcConnection;
$DBConn2.ConnectionString = $DBConnectionString2;
$DBConn2.Open();
$DBCmd3 = $DBConn2.CreateCommand();
$DBCmd3.CommandText = "INSERT INTO best_customers_402890 SELECT first_name, last_name, email, lat, long FROM customers_402890 WHERE ST_DistanceSpheroid(ST_MakePoint(CAST(lat as REAL),CAST(long as REAL)), ST_MakePoint(41.39988501005976, -75.67329768604034),'SPHEROID[""WGS 84"", 6378137,298.257223563]') <=50000;";
$rdr3 = $DBCmd3.ExecuteReader();
$tbl3 = New-Object Data.DataTable;
$tbl3.Load($rdr3);
$rdr3.Close();

Write-Output ($date + " - " + "Użycie kwerendy SQL" +" - "+"SUKCES") >> $log
}catch{Write-Output ($date + " - " + "Użycie kwerendy SQL" +" - "+"BŁĄD") >> $log}


#Export danych do pliku CSV
try{

$DBConnectionString = "Driver={PostgreSQL UNICODE(x64)};Server=$MyServer;Port=$MyPort;Database=$MyDB;Uid=$MyUid;Pwd=$MyPass;"
$DBConn = New-Object System.Data.Odbc.OdbcConnection;
$DBConn.ConnectionString = $DBConnectionString;
$DBConn.Open();

$DBCmd2 = $DBConn.CreateCommand();
$DBCmd2.CommandText = "COPY best_customers_402890 to 'C:\Users\cw8\best_customers_402890.csv' CSV HEADER;";
$rdr2 = $DBCmd2.ExecuteReader();
$tbl2 = New-Object Data.DataTable;
$tbl2.Load($rdr2);
$rdr2.Close();
$tbl2 | Format-Table -AutoSize

Write-Output ($date + " - " + "Eksport danych do pliku CSV" +" - "+"SUKCES") >> $log
}catch{Write-Output ($date + " - " + "Eksport danych do pliku CSV" +" - "+"BŁĄD") >> $log}

#Kompresja pliku do .zip 
try{

if (-not(Test-Path -Path "C:\Users\cw8\best_customers_402890.zip" -PathType Leaf)){Compress-Archive -Path "C:\Users\cw8\best_customers_402890.csv" -DestinationPath "C:\Users\cw8\best_customers_402890.zip" }

Write-Output ($date + " - " + "Kompresja pliku" +" - "+"SUKCES") >> $log
}catch{Write-Output ($date + " - " + "Kompresja pliku" +" - "+"BŁĄD") >> $log}


#Wysłanie e-mail z załącznikiem
try{
$csv4=(Get-Content -Path (-join ( $path,"\best_customers_402890.csv"))).Length
$lastWriteTime=Get-Item (-join ( $path,"\best_customers_402890.csv")) | Select-Object  @{N=’Date of last modification’; E={$_.LastWriteTime}}
$path2=-join($path,"\best_customers_402890.zip")

function Send-ToEmail2([string]$email,[string]$attachmentpath){
    $emailSmtpServer = "mail"
    $emailSmtpServerPort = "587"
    $message = new-object Net.Mail.MailMessage
    $message.From = "raportcustomers@gmail.com"
    $message.To.Add($email)
    $message.Subject = "CUSTOMERS LOAD - ${TIMESTAMP}"
    $message.Body = "
                     number of lines in the input file: $csv4
                     $lastWriteTime
     
    "
    $attachment = New-Object Net.Mail.Attachment($attachmentpath)
    $message.Attachments.Add($attachment)

    $smtp = new-object Net.Mail.SmtpClient("smtp.gmail.com", "587")
    $smtp.EnableSSL = $true
    $smtp.Credentials = New-Object System.Net.NetworkCredential($Username, $EmailPassword)
    $smtp.send($message);
    write-host "Message 2 sent"
    $attachment.Dispose()
 }
Send-ToEmail2  -email "dominikaszx@gmail.com" -attachmentpath $path2;

Write-Output ($date + " - " + "Wysłanie e-mail z załącznikiem" +" - "+"SUKCES") >> $log
}catch{Write-Output ($date + " - " + "Wysłanie e-mail z załącznikiem" +" - "+"BŁĄD") >> $log}


