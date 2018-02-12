# -------- get the list of available ADs

data "oci_identity_availability_domains" "ADs" {
  compartment_id = "${var.tenancy_ocid}"
}

# ------ Create a new VCN

variable "VCN-CIDR" { default = "10.0.0.0/16" }

resource "oci_core_virtual_network" "letsencrypt-vcn" {
  cidr_block = "${var.VCN-CIDR}"
  compartment_id = "${var.compartment_ocid}"
  display_name = "letsencrypt-vcn"
  dns_label = "letsencryptvcn"
}

# ------ Create a new Internet Gateway

resource "oci_core_internet_gateway" "letsencrypt-ig" {
  compartment_id = "${var.compartment_ocid}"
  display_name = "letsencrypt-internet-gateway"
  vcn_id = "${oci_core_virtual_network.letsencrypt-vcn.id}"
}

# ------ Create a new Route Table

resource "oci_core_route_table" "letsencrypt-rt" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id = "${oci_core_virtual_network.letsencrypt-vcn.id}"
  display_name = "letsencrypt-route-table"
  
  route_rules {
    cidr_block = "0.0.0.0/0"
    network_entity_id = "${oci_core_internet_gateway.letsencrypt-ig.id}"
  }
}

# ------ Create a new security list to be used in the new subnet

resource "oci_core_security_list" "letsencrypt-subnet1-sl" {
  compartment_id = "${var.compartment_ocid}"
  display_name = "letsencrypt-subnet1-security-list"

  vcn_id = "${oci_core_virtual_network.letsencrypt-vcn.id}"
  egress_security_rules = [{
    protocol = "all"
    destination = "0.0.0.0/0"
  }]


  ingress_security_rules = [{
    protocol = "6" # tcp
    source = "${var.VCN-CIDR}"
    },
    {
    protocol = "6" # tcp
    source = "0.0.0.0/0"
    source = "${var.authorized_ips}"
    tcp_options {
      "min" = 22
      "max" = 22
    }
  },
    {
    protocol = "6" # tcp
    source = "0.0.0.0/0"
    source = "${var.authorized_ips}"
    tcp_options {
      "min" = 80
      "max" = 80
    }
  },
    {
    protocol = "6" # tcp
    source = "0.0.0.0/0"
    source = "${var.authorized_ips}"
    tcp_options {
      "min" = 443
      "max" = 443
    }
  }
  ]
}


# ------ Create a public subnet 1 in AD1 in the new VCN

resource "oci_core_subnet" "letsencrypt-public-subnet1" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1],"name")}"
  cidr_block = "10.0.1.0/24"
  display_name = "letsencrypt-public-subnet1"
  dns_label = "subnet1"
  compartment_id = "${var.compartment_ocid}"
  vcn_id = "${oci_core_virtual_network.letsencrypt-vcn.id}"
  route_table_id = "${oci_core_route_table.letsencrypt-rt.id}"
  security_list_ids = ["${oci_core_security_list.letsencrypt-subnet1-sl.id}"]
  dhcp_options_id = "${oci_core_virtual_network.letsencrypt-vcn.default_dhcp_options_id}"
}
