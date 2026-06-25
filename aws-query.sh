#!/bin/bash
aws s3 ls
aws dynamodb list-tables --region us-east-2
aws lambda list-functions --region us-east-2
aws apigatewayv2 get-apis --region us-east-2
aws cloudfront list-distributions
aws route53 list-hosted-zones
aws route53 list-resource-record-sets --hosted-zone-id Z09186321HTMYVWMGSPA6
