# Phase 8e — DNS / TLS

## Current approach (GoDaddy stays authoritative)

Apex DNS for `gurujix.com` (including `remote`) stays on **GoDaddy**.  
Terraform creates:

| Resource | Notes |
| --- | --- |
| Route53 zone `gurujix.com` | Optional / unused for public DNS until a future cutover |
| ACM cert | `platform.gurujix.com` + `app.gurujix.com` |

Terraform does **not** wait on ACM validation (that hung when NS were not cut over).

## Unstick a hung apply

```sh
# Ctrl+C the stuck apply, then:
terraform state rm 'aws_acm_certificate_validation.public[0]'
terraform state rm 'aws_route53_record.acm_validation["platform.gurujix.com"]'
# remove any other acm_validation records listed by: terraform state list | grep acm
terraform apply -var='enable_eks=false'
```

## Finish the cert (keep remote up)

```sh
terraform output acm_dns_validation_records
```

In GoDaddy → DNS → **Add** each as a **CNAME** (name/value from the output).  
Do **not** change the GoDaddy NS records.

When ACM status is **ISSUED**, the cert is ready for a future ALB/CloudFront.

## Optional: drop unused Route53 zone

If you only need the cert + GoDaddy validation:

```sh
terraform state rm 'aws_route53_zone.root[0]'
# then delete the empty zone in AWS console, or destroy and recreate without the zone later
```

Or leave the zone (~$0.50/mo) for a future migration.
