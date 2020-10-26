data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_dms_endpoint" "mysql_source" {
  database_name = "mysql"
  endpoint_id   = "source-mysql"
  endpoint_type = "source"
  engine_name   = "mysql"
  password      = var.db_password
  username      = var.db_username
  port          = 3306
  server_name   = var.db_hostname
  ssl_mode      = "none"
  tags = {
    Name = "DMS Source Mysql"
  }
}

# The extra_connection_attributes does not seem to be supported, see
# https://github.com/hashicorp/terraform/issues/2629
resource "aws_dms_endpoint" "s3_target" {
  database_name = "s3"
  endpoint_id   = "target-s3"
  endpoint_type = "target"
  engine_name   = "s3"
  s3_settings {
    bucket_name             = var.dms_target_bucket_name
    service_access_role_arn = var.dms_s3_access_role_arn
  }
  #   extra_connection_attributes = "dataFormat=parquet;includeOpForFullLoad=y"
  ssl_mode = "none"
  tags = {
    Name = "DMS Target S3"
  }

}

resource "aws_dms_replication_subnet_group" "dms_replication_subnet_group" {
  replication_subnet_group_description = "Test replication subnet group"
  replication_subnet_group_id          = "test-dms-replication-subnet-group-tf"
  subnet_ids = [
    var.public_a_subnet_id,
    var.public_b_subnet_id
  ]
  depends_on = [
    var.dms_vpc_management_role
  ]
  tags = {
    Name = "Test DMS subnet group"
  }
}

# Create a new replication instance
resource "aws_dms_replication_instance" "dms_replication_instance" {
  allocated_storage           = 20
  apply_immediately           = true
  auto_minor_version_upgrade  = true
  availability_zone           = data.aws_availability_zones.available.names[0]
  engine_version              = "3.1.4"
  multi_az                    = false
  publicly_accessible         = true
  replication_instance_class  = "dms.t2.micro"
  replication_instance_id     = "test-dms-replication-instance-tf"
  replication_subnet_group_id = aws_dms_replication_subnet_group.dms_replication_subnet_group.id

  tags = {
    Name = "Test DMS replication instance"
  }

  vpc_security_group_ids = [
    var.vpc_rds_security_group_id,
    var.vpc_instance_security_group_id
  ]
}

resource "aws_dms_replication_task" "replication_task" {
  migration_type            = "full-load-and-cdc"
  replication_instance_arn  = aws_dms_replication_instance.dms_replication_instance.replication_instance_arn
  replication_task_id       = "mysql-to-s3"
  source_endpoint_arn       = aws_dms_endpoint.mysql_source.endpoint_arn
  target_endpoint_arn       = aws_dms_endpoint.s3_target.endpoint_arn
  replication_task_settings = <<EOF
{
  "TargetMetadata": {
    "TargetSchema": "",
    "SupportLobs": true,
    "FullLobMode": false,
    "LobChunkSize": 64,
    "LimitedSizeLobMode": true,
    "LobMaxSize": 32,
    "InlineLobMaxSize": 0,
    "LoadMaxFileSize": 0,
    "ParallelLoadThreads": 0,
    "ParallelLoadBufferSize": 0,
    "BatchApplyEnabled": false,
    "TaskRecoveryTableEnabled": false,
    "ParallelLoadQueuesPerThread": 0,
    "ParallelApplyThreads": 0,
    "ParallelApplyBufferSize": 0,
    "ParallelApplyQueuesPerThread": 0
  },
  "FullLoadSettings": {
    "CreatePkAfterFullLoad": false,
    "StopTaskCachedChangesApplied": false,
    "StopTaskCachedChangesNotApplied": false,
    "MaxFullLoadSubTasks": 8,
    "TransactionConsistencyTimeout": 600,
    "CommitRate": 10000
  },
  "Logging": {
    "EnableLogging": false,
    "LogComponents": [
      {
        "Id": "SOURCE_UNLOAD",
        "Severity": "LOGGER_SEVERITY_DEFAULT"
      },
      {
        "Id": "SOURCE_CAPTURE",
        "Severity": "LOGGER_SEVERITY_DEFAULT"
      },
      {
        "Id": "TARGET_LOAD",
        "Severity": "LOGGER_SEVERITY_DEFAULT"
      },
      {
        "Id": "TARGET_APPLY",
        "Severity": "LOGGER_SEVERITY_DEFAULT"
      },
      {
        "Id": "TASK_MANAGER",
        "Severity": "LOGGER_SEVERITY_DEFAULT"
      }
    ],
    "CloudWatchLogGroup": null,
    "CloudWatchLogStream": null
  },
  "ControlTablesSettings": {
    "historyTimeslotInMinutes": 5,
    "ControlSchema": "",
    "HistoryTimeslotInMinutes": 5,
    "HistoryTableEnabled": false,
    "SuspendedTablesTableEnabled": false,
    "StatusTableEnabled": false
  },
  "StreamBufferSettings": {
    "StreamBufferCount": 3,
    "StreamBufferSizeInMB": 8,
    "CtrlStreamBufferSizeInMB": 5
  },
  "ChangeProcessingDdlHandlingPolicy": {
    "HandleSourceTableDropped": true,
    "HandleSourceTableTruncated": true,
    "HandleSourceTableAltered": true
  },
  "ErrorBehavior": {
    "DataErrorPolicy": "LOG_ERROR",
    "DataTruncationErrorPolicy": "LOG_ERROR",
    "DataErrorEscalationPolicy": "SUSPEND_TABLE",
    "DataErrorEscalationCount": 0,
    "TableErrorPolicy": "SUSPEND_TABLE",
    "TableErrorEscalationPolicy": "STOP_TASK",
    "TableErrorEscalationCount": 0,
    "RecoverableErrorCount": -1,
    "RecoverableErrorInterval": 5,
    "RecoverableErrorThrottling": true,
    "RecoverableErrorThrottlingMax": 1800,
    "RecoverableErrorStopRetryAfterThrottlingMax": false,
    "ApplyErrorDeletePolicy": "IGNORE_RECORD",
    "ApplyErrorInsertPolicy": "LOG_ERROR",
    "ApplyErrorUpdatePolicy": "LOG_ERROR",
    "ApplyErrorEscalationPolicy": "LOG_ERROR",
    "ApplyErrorEscalationCount": 0,
    "ApplyErrorFailOnTruncationDdl": false,
    "FullLoadIgnoreConflicts": true,
    "FailOnTransactionConsistencyBreached": false,
    "FailOnNoTablesCaptured": false
  },
  "ChangeProcessingTuning": {
    "BatchApplyPreserveTransaction": true,
    "BatchApplyTimeoutMin": 1,
    "BatchApplyTimeoutMax": 30,
    "BatchApplyMemoryLimit": 500,
    "BatchSplitSize": 0,
    "MinTransactionSize": 1000,
    "CommitTimeout": 1,
    "MemoryLimitTotal": 1024,
    "MemoryKeepTime": 60,
    "StatementCacheSize": 50
  },
  "PostProcessingRules": null,
  "CharacterSetSettings": null,
  "LoopbackPreventionSettings": null,
  "BeforeImageSettings": null
}
  EOF
  table_mappings            = <<EOF
{
  "rules": [
    {
      "rule-type": "selection",
      "rule-id": "1",
      "rule-name": "1",
      "object-locator": {
        "schema-name": "test_db",
        "table-name": "%"
      },
      "rule-action": "include",
      "filters": []
    }
  ]
}
  EOF
}
