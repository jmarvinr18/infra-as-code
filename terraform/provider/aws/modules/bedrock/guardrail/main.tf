resource "aws_bedrock_guardrail" "this" {
  name        = var.name
  description = var.description

  blocked_input_messaging   = var.blocked_input_messaging
  blocked_outputs_messaging = var.blocked_outputs_messaging
  kms_key_arn               = var.kms_key_arn

  # ───────────────────────────────────────────────────────────────────────────
  # Contextual grounding.
  #
  # GROUNDING scores the response against the source material handed to the
  # model; RELEVANCE scores it against the question asked. This is the outer
  # net for a briefing that must not invent a figure — it is not a substitute
  # for verifying citations against tool output programmatically, which is
  # deterministic and free. Raise the threshold to block more; 0.0 disables.
  # ───────────────────────────────────────────────────────────────────────────

  dynamic "contextual_grounding_policy_config" {
    for_each = length(var.contextual_grounding_filters) > 0 ? [1] : []
    content {
      dynamic "filters_config" {
        for_each = var.contextual_grounding_filters
        content {
          type      = filters_config.value.type
          threshold = filters_config.value.threshold
        }
      }
    }
  }

  dynamic "content_policy_config" {
    for_each = length(var.content_filters) > 0 ? [1] : []
    content {
      dynamic "filters_config" {
        for_each = var.content_filters
        content {
          type            = filters_config.value.type
          input_strength  = filters_config.value.input_strength
          output_strength = filters_config.value.output_strength
        }
      }
    }
  }

  dynamic "topic_policy_config" {
    for_each = length(var.denied_topics) > 0 ? [1] : []
    content {
      dynamic "topics_config" {
        for_each = var.denied_topics
        content {
          name       = topics_config.value.name
          type       = "DENY"
          definition = topics_config.value.definition
          examples   = topics_config.value.examples
        }
      }
    }
  }

  dynamic "word_policy_config" {
    for_each = length(var.blocked_words) > 0 || length(var.managed_word_lists) > 0 ? [1] : []
    content {
      dynamic "words_config" {
        for_each = var.blocked_words
        content {
          text = words_config.value
        }
      }

      dynamic "managed_word_lists_config" {
        for_each = var.managed_word_lists
        content {
          type = managed_word_lists_config.value
        }
      }
    }
  }

  # Adoption data carries staff identifiers. ANONYMIZE keeps a briefing useful
  # while stripping the person out of it; BLOCK refuses the response entirely.
  dynamic "sensitive_information_policy_config" {
    for_each = length(var.pii_entities) > 0 || length(var.regex_filters) > 0 ? [1] : []
    content {
      dynamic "pii_entities_config" {
        for_each = var.pii_entities
        content {
          type   = pii_entities_config.value.type
          action = pii_entities_config.value.action
        }
      }

      dynamic "regexes_config" {
        for_each = var.regex_filters
        content {
          name        = regexes_config.value.name
          description = regexes_config.value.description
          pattern     = regexes_config.value.pattern
          action      = regexes_config.value.action
        }
      }
    }
  }

  tags = var.tags
}

# A guardrail is only usable from an application at a published version — the
# DRAFT working copy is for editing. Republishing on every change keeps the
# version the agent references in step with the policy above.
resource "aws_bedrock_guardrail_version" "this" {
  count = var.create_version ? 1 : 0

  guardrail_arn = aws_bedrock_guardrail.this.guardrail_arn
  description   = var.version_description

  lifecycle {
    create_before_destroy = true
  }
}
