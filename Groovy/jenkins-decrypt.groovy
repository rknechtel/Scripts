# Script Name: jenkins-decrypt.groovy
# LICENSE: 
# This script is in the public domain, free from copyrights or restrictions.
#To Decrypt Jenkins Password from credentials.xml
#<username>jenkins</username>
#<passphrase>your-sercret-hash-S0SKVKUuFfUfrY3UhhUC3J</passphrase>


#go to the jenkins url 
http://jenkins-host/script

#In the console paste the script
hashed_pw='your-sercret-hash-S0SKVKUuFfUfrY3UhhUC3J'
passwd = hudson.util.Secret.decrypt(hashed_pw)
println(passwd)
