output docker-build {
  value = module.ecr-docker-image.build
}

output docker-push {
  value = module.ecr-docker-image.push
}