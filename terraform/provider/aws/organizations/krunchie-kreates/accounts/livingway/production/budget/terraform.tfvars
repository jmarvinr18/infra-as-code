

budget_name = "donato-and-zarate-monthly-50"
budget_type = "COST"
monthly_limit = 50
limit_unit = "USD"
time_unit = "MONTHLY"
client = "donato-and-zarate"
environment = "production"
region = "ap-southeast-1"


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