variable "env_id"{
    type=string
    description="environment id"
    default="dev"
}

variable "sql_pass" {
    type = string
    description = "The SQL Server password"
}

variable "location" {
    type=string
    description="resource location"
    default="East US"
}

variable "location2" {
    type=string
    description="resource location"
    default="East US 2"
}

variable "src_key" {
    type=string
    description = "infrastructure source"
    default="terraform"
}










variable "subscription_id" {
    type = string
    description = "Azure subscription id"
    default = "c98a8f65-7901-4be9-b1b7-ba2c415a46fe"
}
