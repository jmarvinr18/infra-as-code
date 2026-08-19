##########################################
##   GLOBAL
##########################################'

client_account_id = "431445330841"
client = "donato-and-zarate"
environment = "production"
region = "ap-southeast-1"

##########################################
##   VPC
##########################################
vpc_cidr = "10.20.0.0/16"
single_nat = false

##########################################
##   BUDGET
##########################################

budget_name = "donato-and-zarate-monthly-50"
budget_type = "COST"
monthly_limit = 50
limit_unit = "USD"
time_unit = "MONTHLY"

notifications = [ 
    {
        comparison_operator        = "GREATER_THAN"
        threshold                  = 100
        threshold_type             = "PERCENTAGE"
        notification_type          = "ACTUAL"
        subscriber_email_addresses = ["jmarvin.ramoda@gmail.com"]
    },
    {
        comparison_operator        = "GREATER_THAN"
        threshold                  = 80
        threshold_type             = "PERCENTAGE"
        notification_type          = "ACTUAL"
        subscriber_email_addresses = ["jmarvin.ramoda@gmail.com"]
    },
    {
        comparison_operator        = "GREATER_THAN"
        threshold                  = 100
        threshold_type             = "PERCENTAGE"
        notification_type          = "FORECASTED"
        subscriber_email_addresses = ["jmarvin.ramoda@gmail.com"]
    }    
]


