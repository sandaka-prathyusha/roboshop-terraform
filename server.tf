
resource "aws_instance" "instance" {
  for_each      = var.components
  ami           = data.aws_ami.centos.image_id
  instance_type = each.value["instance_type"]
  vpc_security_group_ids = [data.aws_security_group.allow-all.id]

  tags = {
    Name = each.value["name"]
  }


#
#connection can be within provisioner or outside

  provisioner "remote-exec" {

    connection {
     type     = "ssh"
     user     = "centos"
     password = "DevOps321"
     host     = self.private-ip
   }
  inline = [
    #i have to declare list of commands here
    "rm -rf roboshop-shell",
    "git clone https://github.com/nandu18/roboshop-shell",
    "cd roboshop-shell",
    "sudo bash ${each.value["name"]}.sh"

  ]
 }
}



resource "aws_route53_record" "records" {
  for_each = var.components
  #how many times i need to loop its  as same as var.components
  zone_id = "Z001151113ESNLT809BTY"
  name    = "${each.value["name"]}-dev.nandu18.online"
  //need to know about $ here// bcoz its a combination of some other string
  type    = "A"
  ttl     = 30
  records = [aws_instance.instance[each.value["name"]].private_ip]
}


