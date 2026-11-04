# Cost Considerations

## Breakdown

| Type                         | Count | Monthly Cost |
|------------------------------|-------|--------------|
| aws_nat_gateway              |    1  |         $33  |
| aws_lb                       |    1  |        $16   |
| aws_instance                 |    1  |         $15  |
| aws_autoscaling_group        |    1  |         $11  |
| aws_secretsmanager_secret    |    1 |         $0  |
| aws_cloudwatch_metric_alarm  |    1 |         $0  |
| aws_iam_role                 |    2 |         $0  |
| aws_route                    |    2 |         $0  |
| aws_route_table_association  |    6 |         $0  |
| aws_lb_target_group          |    1 |         $0  |

## Additional thoughts / considerations

- Single NAT gateway
- Lifecycle policy on S3 objects using Intelligent-Tiering
- S3 should delete failed multi-part uploads
- Integrate infracost into pre-commit/CI pull-request checks
