output "heroku_access_key" {
  description = "AWS ACCESS_KEY_ID for prospector"
  value       = aws_iam_access_key.heroku.id
}
output "heroku_secret_key" {
  description = "Encrypted AWS secret key for prospector"
  value       = aws_iam_access_key.heroku.encrypted_secret
}
