#In this example we have the users john and mery, the id_rsa.pub of john looks like this:
#ssh-rsa asdfsavasdfgasasdgsdfSDFSDGsdFGRsdfgdf john@pc
#And mery one looks like this:
#ssh-rsa agjasdfbhkawergjerfkgf mery@laptop
#So as you can notice we only use from that file the key properly said
class{"admin_tools":
	admins =>   {john => 'asdfsavasdfgasasdgsdfSDFSDGsdFGRsdfgdf',mery => 'agjasdfbhkawergjerfkgf'}
}
