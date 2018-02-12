variable "InstanceImageOCID" {
  type = "map"
  default = {
    // Oracle-provided image "Oracle-Linux-7.4-2017.12.18-0"
    // See https://docs.us-phoenix-1.oraclecloud.com/Content/Resources/Assets/OracleProvidedImageOCIDs.pdf
    us-phoenix-1 = "ocid1.image.oc1.phx.aaaaaaaav4gjc4l232wx5g5drypbuiu375lemgdgnc7zg2wrdfmmtbtyrc5q"
    us-ashburn-1 = "ocid1.image.oc1.iad.aaaaaaaautkmgjebjmwym5i6lvlpqfzlzagvg5szedggdrbp6rcjcso3e4kq"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaajdge4yzm5j7ci7ryzte7f3qgcekljjw7p6nexhnsvwt6hoybcu3q"
  }
}
 
# ------ Create a compute instance from the more recent Oracle Linux 7.4 image

resource "oci_core_instance" "letsencrypt-ol7" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1],"name")}"
  compartment_id = "${var.compartment_ocid}"
  display_name = "letsencrypt-ol7"
  hostname_label = "letsencrypt-ol7"
  image = "${var.InstanceImageOCID[var.region]}"

  shape = "VM.Standard1.1"
  subnet_id = "${oci_core_subnet.letsencrypt-public-subnet1.id}"
  metadata {
    ssh_authorized_keys = "${file(var.ssh_public_key_file_ol7oci)}"
  }


  timeouts {
    create = "30m"
  }
}


# ------ Display the public IP of instance
output " Public IP of instance " {
  value = ["${oci_core_instance.letsencrypt-ol7.public_ip}"]
}
