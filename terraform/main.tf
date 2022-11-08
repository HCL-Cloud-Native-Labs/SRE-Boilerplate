resource "local_file" "changeme_local_file_hello" {
  content  = "Hello terraform local!"
  filename = "${path.module}/changeme_local_file_hello_${terraform.workspace}.txt"
}
