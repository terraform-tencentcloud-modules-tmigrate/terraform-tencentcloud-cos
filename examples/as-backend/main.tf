provider tencentcloud {
  region = "ap-nanjing"
}

module "cos-backend" {
  source = "../../"

  tags = {
    owner = "multi-cloud"
  }
  appid = "0000000000"
  name = "test-backend-tf"

}
