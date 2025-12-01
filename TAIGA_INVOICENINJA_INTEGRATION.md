# Taiga + InvoiceNinja Integration Guide

**Integration for Automated Time Tracking and Invoice Generation**

---

## Overview

This document outlines how to integrate Taiga (self-hosted project management) with InvoiceNinja (invoicing system) to automatically track billable hours and generate invoices from project tasks.

## Integration Feasibility

✅ **Yes, it is fully possible** to connect Taiga and InvoiceNinja for automated billing workflows.

Both platforms provide comprehensive REST APIs with:
- **Taiga**: Tasks, time tracking, webhooks, custom attributes
- **InvoiceNinja**: Time entries, projects, invoices, clients, webhooks

---

## Taiga API Capabilities

### Key Endpoints for Time Tracking

| Endpoint | Purpose |
|----------|---------|
| `/api/v1/tasks` | Task CRUD with duration, assigned user, status |
| `/api/v1/userstories` | User stories with time estimates |
| `/api/v1/projects` | Project details with team members |
| `/api/v1/history/task/{taskId}` | Task change history and time logs |
| `/api/v1/webhooks` | Real-time notifications for task events |
| `/api/v1/task-custom-attributes` | Custom fields for billable hours, rates |

### Available Task Data

```json
{
  "id": 123,
  "ref": 45,
  "subject": "Implement payment gateway",
  "assigned_to": 15,
  "created_date": "2025-12-01T09:00:00Z",
  "finished_date": "2025-12-01T14:30:00Z",
  "milestone": 1,
  "status": "Done",
  "custom_attributes_values": {
    "duration_hours": 4.5,
    "billable": true,
    "hourly_rate": 75.00,
    "client_id": "INV_CLIENT_123"
  }
}
```

### Webhook Events

Taiga webhooks can trigger on:
- Task creation
- Task status change
- Task completion
- Task assignment
- Custom attribute updates

**Webhook payload example:**
```json
{
  "action": "change",
  "type": "task",
  "by": {
    "id": 6,
    "username": "developer",
    "full_name": "John Developer"
  },
  "data": {
    "id": 123,
    "ref": 45,
    "subject": "Task subject",
    "status": "Done",
    "is_closed": true,
    "custom_attributes_values": {
      "duration_hours": 4.5
    }
  }
}
```

---

## InvoiceNinja API Capabilities

### Key Endpoints for Billing

| Endpoint | Purpose |
|----------|---------|
| `/api/v1/tasks` | Time tracking entries |
| `/api/v1/projects` | Project management |
| `/api/v1/clients` | Client management |
| `/api/v1/invoices` | Invoice generation |
| `/api/v1/products` | Service catalog with rates |

### Time Entry Creation

```bash
POST /api/v1/tasks
{
  "project_id": "proj_abc123",
  "client_id": "client_xyz789",
  "description": "Task #45: Implement payment gateway",
  "time_log": "[[1733047200,1733063400]]",  # Unix timestamps
  "rate": 75.00,
  "is_billable": true
}
```

### Invoice Generation

```bash
POST /api/v1/invoices
{
  "client_id": "client_xyz789",
  "line_items": [
    {
      "product_key": "Consulting",
      "notes": "Task #45: Implement payment gateway",
      "quantity": 4.5,
      "cost": 75.00
    }
  ],
  "auto_bill_enabled": true
}
```

---

## Integration Architectures

### Option A: Custom Middleware Service (Recommended)

**Architecture:**
```
Taiga → Webhook → Middleware Service → InvoiceNinja
                        ↓
                  Database (sync state)
```

**Features:**
- Real-time task-to-invoice sync
- Bidirectional data mapping
- Error handling and retry logic
- Audit trail and logging
- Configuration management

**Technology Stack:**
- Python (Flask/FastAPI) or Node.js (Express)
- PostgreSQL for state management
- Redis for webhook queue
- Docker for deployment

---

### Option B: Taiga Custom Attributes + Scheduled Sync

**Architecture:**
```
Taiga Tasks (with custom fields)
       ↓
   Cron Job (hourly/daily)
       ↓
  Sync Script
       ↓
  InvoiceNinja
```

**Setup Steps:**

1. **Add Custom Attributes to Taiga Tasks:**
   - `billable` (checkbox) - Mark if task is billable
   - `duration_hours` (number) - Hours spent on task
   - `hourly_rate` (number) - Rate for this task
   - `client_invoice_id` (text) - InvoiceNinja client ID
   - `invoice_status` (dropdown) - pending/invoiced/non-billable

2. **Create Sync Script:**
   - Query Taiga for tasks with `invoice_status = pending`
   - Extract billable hours and rates
   - Create time entries in InvoiceNinja
   - Update Taiga tasks to `invoice_status = invoiced`

3. **Schedule Execution:**
   - Daily sync: Aggregate time entries
   - Monthly: Generate invoices for clients

---

### Option C: Webhook-Driven Real-Time Sync (Best for Accuracy)

**Flow:**
```
1. Task completed in Taiga
   ↓
2. Webhook fires to middleware
   ↓
3. Middleware validates billable status
   ↓
4. Extract time data from custom attributes
   ↓
5. Create time entry in InvoiceNinja
   ↓
6. Update task status in Taiga
```

**Advantages:**
- Immediate sync (no delay)
- Accurate time tracking
- Minimal data loss risk
- Easy to debug
- Scalable

---

## Implementation Details

### Phase 1: Taiga Configuration

#### 1. Add Custom Attributes

Navigate to Taiga Admin → Settings → Attributes:

**For Tasks:**
```
Name: Billable
Type: Checkbox
Description: Mark if this task should be invoiced

Name: Duration (Hours)
Type: Number
Description: Time spent on this task in hours

Name: Hourly Rate
Type: Number
Description: Billing rate for this task (overrides default)

Name: Client Invoice ID
Type: Text
Description: InvoiceNinja client ID for billing

Name: Invoice Status
Type: Dropdown
Options: Not Billable, Pending Invoice, Invoiced
Description: Current invoice status
```

#### 2. Configure Webhooks

Admin → Integrations → Webhooks:
```
Name: InvoiceNinja Sync
URL: https://your-middleware.com/webhooks/taiga
Key: your-secret-webhook-key
Events: Task changes
```

---

### Phase 2: Middleware Development

#### Python Flask Example

```python
from flask import Flask, request, jsonify
import requests
from datetime import datetime

app = Flask(__name__)

# Configuration
TAIGA_API = "https://taiga.dix30.be/api/v1"
TAIGA_TOKEN = "your-taiga-auth-token"
INVOICE_NINJA_API = "https://your-invoiceninja.com/api/v1"
INVOICE_NINJA_TOKEN = "your-invoiceninja-token"

# Webhook secret for security
WEBHOOK_SECRET = "your-secret-webhook-key"

@app.route('/webhooks/taiga', methods=['POST'])
def taiga_webhook():
    """Handle incoming Taiga webhooks"""
    
    # Verify webhook signature
    signature = request.headers.get('X-TAIGA-WEBHOOK-SIGNATURE')
    if not verify_signature(signature, request.data, WEBHOOK_SECRET):
        return jsonify({'error': 'Invalid signature'}), 403
    
    data = request.json
    
    # Process only task completion events
    if data['type'] != 'task' or data['action'] != 'change':
        return jsonify({'status': 'ignored'}), 200
    
    task = data['data']
    
    # Check if task is closed and billable
    if not task.get('is_closed'):
        return jsonify({'status': 'not_closed'}), 200
    
    custom_attrs = task.get('custom_attributes_values', {})
    
    if not custom_attrs.get('billable', False):
        return jsonify({'status': 'not_billable'}), 200
    
    # Extract billing information
    duration = custom_attrs.get('duration_hours', 0)
    rate = custom_attrs.get('hourly_rate', 0)
    client_id = custom_attrs.get('client_invoice_id')
    
    if duration <= 0 or not client_id:
        return jsonify({'error': 'Missing billing data'}), 400
    
    # Create time entry in InvoiceNinja
    try:
        create_time_entry(
            client_id=client_id,
            project_id=task['project'],
            task_ref=task['ref'],
            description=task['subject'],
            duration=duration,
            rate=rate,
            date=task['finished_date']
        )
        
        # Update Taiga task status to "Invoiced"
        update_task_invoice_status(task['id'], 'invoiced')
        
        return jsonify({'status': 'success'}), 200
        
    except Exception as e:
        app.logger.error(f"Error processing task {task['id']}: {str(e)}")
        return jsonify({'error': str(e)}), 500


def create_time_entry(client_id, project_id, task_ref, description, 
                      duration, rate, date):
    """Create time entry in InvoiceNinja"""
    
    # Convert duration to time log format (start/end timestamps)
    end_time = int(datetime.fromisoformat(date.replace('Z', '+00:00')).timestamp())
    start_time = end_time - int(duration * 3600)
    
    payload = {
        "client_id": client_id,
        "project_id": map_project_id(project_id),
        "description": f"Task #{task_ref}: {description}",
        "time_log": f"[[{start_time},{end_time}]]",
        "rate": rate,
        "is_billable": True
    }
    
    headers = {
        "X-Api-Token": INVOICE_NINJA_TOKEN,
        "Content-Type": "application/json"
    }
    
    response = requests.post(
        f"{INVOICE_NINJA_API}/tasks",
        json=payload,
        headers=headers
    )
    
    response.raise_for_status()
    return response.json()


def update_task_invoice_status(task_id, status):
    """Update task invoice status in Taiga"""
    
    headers = {
        "Authorization": f"Bearer {TAIGA_TOKEN}",
        "Content-Type": "application/json"
    }
    
    # Get current task to get version
    task_response = requests.get(
        f"{TAIGA_API}/tasks/{task_id}",
        headers=headers
    )
    task = task_response.json()
    
    # Update custom attribute
    payload = {
        "version": task['version'],
        "custom_attributes_values": {
            "invoice_status": status
        }
    }
    
    response = requests.patch(
        f"{TAIGA_API}/tasks/{task_id}",
        json=payload,
        headers=headers
    )
    
    response.raise_for_status()
    return response.json()


def map_project_id(taiga_project_id):
    """Map Taiga project ID to InvoiceNinja project ID"""
    # Store mapping in database or configuration
    project_mapping = {
        1: "proj_abc123",
        2: "proj_xyz789"
    }
    return project_mapping.get(taiga_project_id)


def verify_signature(signature, payload, secret):
    """Verify webhook signature for security"""
    import hmac
    import hashlib
    
    expected = hmac.new(
        secret.encode(),
        payload,
        hashlib.sha1
    ).hexdigest()
    
    return signature == expected


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

#### Invoice Generation Script

```python
#!/usr/bin/env python3
"""
Generate monthly invoices from unbilled time entries
Run this script at the end of each month
"""

import requests
from datetime import datetime, timedelta
from collections import defaultdict

INVOICE_NINJA_API = "https://your-invoiceninja.com/api/v1"
INVOICE_NINJA_TOKEN = "your-invoiceninja-token"

def get_unbilled_time_entries():
    """Fetch all unbilled time entries from InvoiceNinja"""
    
    headers = {
        "X-Api-Token": INVOICE_NINJA_TOKEN,
        "Content-Type": "application/json"
    }
    
    response = requests.get(
        f"{INVOICE_NINJA_API}/tasks?is_billable=true&invoice_id=",
        headers=headers
    )
    
    return response.json()['data']


def aggregate_by_client(time_entries):
    """Group time entries by client"""
    
    client_entries = defaultdict(list)
    
    for entry in time_entries:
        client_id = entry['client_id']
        client_entries[client_id].append(entry)
    
    return client_entries


def create_invoice(client_id, time_entries):
    """Create invoice for client with time entries"""
    
    line_items = []
    
    for entry in time_entries:
        # Parse time log to calculate duration
        time_log = eval(entry['time_log'])  # [[start, end]]
        duration_seconds = time_log[0][1] - time_log[0][0]
        duration_hours = duration_seconds / 3600
        
        line_items.append({
            "product_key": "Consulting",
            "notes": entry['description'],
            "quantity": round(duration_hours, 2),
            "cost": entry['rate']
        })
    
    payload = {
        "client_id": client_id,
        "line_items": line_items,
        "terms": "Payment due within 30 days",
        "footer": "Thank you for your business!",
        "auto_bill_enabled": False  # Set to True for automatic charging
    }
    
    headers = {
        "X-Api-Token": INVOICE_NINJA_TOKEN,
        "Content-Type": "application/json"
    }
    
    response = requests.post(
        f"{INVOICE_NINJA_API}/invoices",
        json=payload,
        headers=headers
    )
    
    if response.status_code == 200:
        invoice = response.json()['data']
        print(f"✓ Invoice #{invoice['number']} created for client {client_id}")
        return invoice
    else:
        print(f"✗ Failed to create invoice for client {client_id}")
        print(response.text)
        return None


def main():
    """Generate monthly invoices"""
    
    print("Fetching unbilled time entries...")
    entries = get_unbilled_time_entries()
    
    if not entries:
        print("No unbilled time entries found.")
        return
    
    print(f"Found {len(entries)} unbilled entries")
    
    # Group by client
    client_entries = aggregate_by_client(entries)
    
    print(f"Generating invoices for {len(client_entries)} clients...")
    
    for client_id, entries in client_entries.items():
        total_hours = sum(
            (eval(e['time_log'])[0][1] - eval(e['time_log'])[0][0]) / 3600 
            for e in entries
        )
        
        print(f"\nClient {client_id}: {len(entries)} entries, {total_hours:.2f} hours")
        
        invoice = create_invoice(client_id, entries)
        
        if invoice:
            print(f"  Invoice total: ${invoice['amount']}")


if __name__ == '__main__':
    main()
```

---

### Phase 3: Deployment

#### Docker Compose Setup

```yaml
version: '3.8'

services:
  middleware:
    build: .
    ports:
      - "5000:5000"
    environment:
      - TAIGA_API=https://taiga.dix30.be/api/v1
      - TAIGA_TOKEN=${TAIGA_TOKEN}
      - INVOICE_NINJA_API=${INVOICE_NINJA_API}
      - INVOICE_NINJA_TOKEN=${INVOICE_NINJA_TOKEN}
      - WEBHOOK_SECRET=${WEBHOOK_SECRET}
    volumes:
      - ./logs:/app/logs
    restart: unless-stopped
    networks:
      - taiga-billing

  redis:
    image: redis:7-alpine
    networks:
      - taiga-billing

  postgres:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=taiga_billing
      - POSTGRES_USER=billing
      - POSTGRES_PASSWORD=${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - taiga-billing

volumes:
  postgres_data:

networks:
  taiga-billing:
```

#### Dockerfile

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4", "app:app"]
```

#### requirements.txt

```
Flask==3.0.0
gunicorn==21.2.0
requests==2.31.0
python-dotenv==1.0.0
redis==5.0.1
psycopg2-binary==2.9.9
```

---

## Configuration Guide

### 1. Project Mapping

Create a mapping table between Taiga and InvoiceNinja:

| Taiga Project | InvoiceNinja Client | InvoiceNinja Project | Default Rate |
|---------------|---------------------|----------------------|--------------|
| Website Redesign | client_abc123 | proj_web001 | $75/hr |
| Mobile App | client_xyz789 | proj_mobile002 | $85/hr |
| API Integration | client_def456 | proj_api003 | $95/hr |

Store in database or configuration file:

```json
{
  "project_mappings": [
    {
      "taiga_project_id": 1,
      "taiga_project_name": "Website Redesign",
      "invoiceninja_client_id": "client_abc123",
      "invoiceninja_project_id": "proj_web001",
      "default_hourly_rate": 75.00
    }
  ]
}
```

### 2. User Mapping

Map Taiga users to hourly rates:

```json
{
  "user_rates": {
    "senior_dev": 95.00,
    "mid_dev": 75.00,
    "junior_dev": 50.00,
    "designer": 70.00,
    "pm": 85.00
  }
}
```

### 3. Billing Rules

Define when invoices should be generated:

```yaml
billing_rules:
  frequency: monthly  # weekly, biweekly, monthly
  generation_day: 1   # Day of month (1-31)
  min_billable_hours: 0.25  # Minimum hours to bill
  rounding: quarter_hour  # none, quarter_hour, half_hour, hour
  auto_send: false  # Automatically email invoices
  payment_terms: net30  # Payment terms
```

---

## Usage Workflow

### For Developers/Team Members

1. **Start working on a task in Taiga**
2. **Mark task as billable:**
   - Check "Billable" custom attribute
   - Enter "Duration (Hours)" when complete
   - Optionally override "Hourly Rate"
3. **Complete the task:**
   - Move to "Done" status
   - Webhook automatically syncs to InvoiceNinja
4. **Verify sync:**
   - Check that "Invoice Status" updates to "Invoiced"

### For Administrators

1. **Monitor webhook logs:**
   ```bash
   tail -f /var/log/taiga-billing/webhook.log
   ```

2. **Generate monthly invoices:**
   ```bash
   python generate_invoices.py --month 2025-12
   ```

3. **Review draft invoices in InvoiceNinja:**
   - Verify line items
   - Adjust if needed
   - Mark as sent
   - Email to clients

4. **Track payment status:**
   - Monitor invoice payments
   - Send reminders for overdue invoices

---

## Benefits

### ✅ Automation Benefits
- **No manual timesheet entry** - Time tracked directly from tasks
- **Real-time sync** - Immediate update when tasks complete
- **Reduced errors** - Eliminates double-entry and manual calculations
- **Faster billing** - Generate invoices in minutes, not hours

### ✅ Business Benefits
- **Improved cash flow** - Bill clients immediately after work completion
- **Better transparency** - Clients see detailed task-level billing
- **Accurate time tracking** - Capture all billable hours
- **Professional invoices** - Consistent formatting and branding

### ✅ Team Benefits
- **Less administrative work** - No separate timesheet system
- **Clear expectations** - See which tasks are billable
- **Better project tracking** - Time estimates vs. actual
- **Fair compensation tracking** - Hours logged per person

---

## Troubleshooting

### Common Issues

#### 1. Webhook Not Firing

**Symptoms:** Tasks complete but don't sync to InvoiceNinja

**Solutions:**
- Check webhook URL is accessible from Taiga server
- Verify webhook is enabled in Taiga admin
- Check firewall rules
- Review Taiga logs: `journalctl -u taiga -n 100`

#### 2. Authentication Errors

**Symptoms:** 401/403 errors in logs

**Solutions:**
- Verify API tokens are correct and not expired
- Check token has required permissions
- Regenerate tokens if needed

#### 3. Time Entry Duplicates

**Symptoms:** Same task creates multiple invoices

**Solutions:**
- Add idempotency checks (store processed task IDs)
- Use database to track sync status
- Implement webhook deduplication

#### 4. Incorrect Billing Amounts

**Symptoms:** Hours or rates don't match expectations

**Solutions:**
- Verify custom attribute values are set correctly
- Check rate mapping configuration
- Review time calculation logic
- Add validation before creating entries

---

## Security Considerations

### 1. Webhook Security

- ✅ Use HTTPS for all webhook endpoints
- ✅ Verify webhook signatures
- ✅ Implement rate limiting
- ✅ Use strong webhook secrets
- ✅ Log all webhook attempts

### 2. API Token Management

- ✅ Store tokens in environment variables (not in code)
- ✅ Use separate tokens for dev/staging/production
- ✅ Rotate tokens regularly
- ✅ Limit token permissions to minimum required
- ✅ Never commit tokens to version control

### 3. Data Protection

- ✅ Encrypt sensitive data at rest
- ✅ Use TLS for all API communications
- ✅ Implement audit logging
- ✅ Regular backups of sync state
- ✅ GDPR compliance for client data

---

## Maintenance

### Daily Tasks
- Monitor webhook logs for errors
- Check sync status dashboard

### Weekly Tasks
- Review unbilled time entries
- Verify project/client mappings
- Check for stuck/failed syncs

### Monthly Tasks
- Generate invoices
- Review billing accuracy
- Update rate tables if needed
- Archive old logs

---

## Alternative Solutions

If building custom integration is not feasible:

### 1. n8n.io (Recommended)
- **Type:** Open-source workflow automation
- **Hosting:** Self-hosted (Docker)
- **Cost:** Free
- **Features:** Visual workflow builder, Taiga + InvoiceNinja nodes
- **Setup time:** 2-3 hours

### 2. Zapier
- **Type:** Cloud automation platform
- **Cost:** $20+/month
- **Limitations:** May not have native Taiga support
- **Best for:** Quick prototype

### 3. Make.com (Integromat)
- **Type:** Visual automation platform
- **Cost:** Free tier available
- **Features:** Complex logic support
- **Best for:** Non-developers

---

## Cost Estimation

### Custom Development
- **Initial development:** 5-10 days ($4,000-$8,000)
- **Testing & deployment:** 2-3 days ($1,500-$2,500)
- **Documentation:** 1 day ($800)
- **Total:** $6,300-$11,300

### Ongoing Costs
- **Hosting:** $10-$50/month (Docker container)
- **Maintenance:** 2-4 hours/month ($200-$400)
- **Support:** As needed

### ROI Analysis
If saves 10 hours/month on manual invoicing:
- Time saved: 10 hours × $50/hour = $500/month
- Annual savings: $6,000
- **Payback period:** ~2 months

---

## Next Steps

### Phase 1: Planning (Week 1)
- [ ] Review integration requirements
- [ ] Map Taiga projects to InvoiceNinja clients
- [ ] Define custom attributes needed
- [ ] Choose integration approach

### Phase 2: Setup (Week 2)
- [ ] Add custom attributes to Taiga
- [ ] Configure Taiga webhooks
- [ ] Setup InvoiceNinja API access
- [ ] Create project/client mappings

### Phase 3: Development (Weeks 3-4)
- [ ] Build webhook receiver
- [ ] Implement sync logic
- [ ] Add error handling
- [ ] Create invoice generation script

### Phase 4: Testing (Week 5)
- [ ] Test with sample data
- [ ] Verify billing calculations
- [ ] Test edge cases
- [ ] Train team on usage

### Phase 5: Deployment (Week 6)
- [ ] Deploy to production
- [ ] Monitor initial syncs
- [ ] Gather feedback
- [ ] Iterate and improve

---

## Support Resources

### Taiga API Documentation
- https://docs.taiga.io/api.html
- https://api.taiga.io/api/v1/

### InvoiceNinja API Documentation
- https://api-docs.invoicing.co/
- https://github.com/invoiceninja/invoiceninja

### Community Support
- Taiga Community: https://community.taiga.io/
- InvoiceNinja Slack: https://invoiceninja.slack.com/

---

## Conclusion

Integrating Taiga with InvoiceNinja provides a powerful automated billing workflow that:
- Saves time on manual invoicing
- Improves billing accuracy
- Provides detailed client transparency
- Streamlines project-to-payment workflow

The webhook-driven approach offers the best balance of real-time accuracy and maintainability, making it the recommended solution for production use.

For your YunoHost Taiga installation at `taiga.dix30.be`, this integration can be deployed as a separate service on the same server or a different machine, providing a robust billing automation system.

---

**Last Updated:** December 1, 2025
**Author:** Taiga YunoHost Integration Team
**Version:** 1.0
