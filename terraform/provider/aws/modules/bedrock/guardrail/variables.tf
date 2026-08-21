variable "name" {
  type = string
}

variable "description" {
  type    = string
  default = ""
}

variable "blocked_input_messaging" {
  description = "Returned to the caller when a prompt is blocked."
  type        = string
  default     = "This request cannot be processed."
}

variable "blocked_outputs_messaging" {
  description = "Returned when a response is blocked. Say that no answer is available rather than implying one exists."
  type        = string
  default     = "A grounded response could not be produced from the available data."
}

variable "kms_key_arn" {
  type    = string
  default = null
}

variable "contextual_grounding_filters" {
  description = "GROUNDING scores the response against source material, RELEVANCE against the query. Threshold is 0.0-0.99; higher blocks more."
  type = list(object({
    type      = string
    threshold = number
  }))
  default = []

  validation {
    condition     = alltrue([for f in var.contextual_grounding_filters : contains(["GROUNDING", "RELEVANCE"], f.type)])
    error_message = "contextual_grounding_filters type must be GROUNDING or RELEVANCE."
  }

  validation {
    condition     = alltrue([for f in var.contextual_grounding_filters : f.threshold >= 0 && f.threshold < 1])
    error_message = "contextual_grounding_filters threshold must be at least 0.0 and below 1.0."
  }
}

variable "content_filters" {
  description = "Harmful-content categories, e.g. SEXUAL, VIOLENCE, HATE, INSULTS, MISCONDUCT, PROMPT_ATTACK. Strength is NONE, LOW, MEDIUM or HIGH."
  type = list(object({
    type            = string
    input_strength  = optional(string, "MEDIUM")
    output_strength = optional(string, "MEDIUM")
  }))
  default = []
}

variable "denied_topics" {
  type = list(object({
    name       = string
    definition = string
    examples   = optional(list(string), [])
  }))
  default = []
}

variable "blocked_words" {
  type    = list(string)
  default = []
}

variable "managed_word_lists" {
  description = "AWS-curated word lists to apply, e.g. [\"PROFANITY\"]."
  type        = list(string)
  default     = []
}

variable "pii_entities" {
  description = "PII types to act on. Action is BLOCK or ANONYMIZE."
  type = list(object({
    type   = string
    action = optional(string, "ANONYMIZE")
  }))
  default = []
}

variable "regex_filters" {
  type = list(object({
    name        = string
    description = optional(string, "")
    pattern     = string
    action      = optional(string, "ANONYMIZE")
  }))
  default = []
}

variable "create_version" {
  description = "Publish an immutable version. Applications reference a version, never DRAFT."
  type        = bool
  default     = true
}

variable "version_description" {
  type    = string
  default = "Managed by terraform"
}

variable "tags" {
  type    = map(string)
  default = {}
}
