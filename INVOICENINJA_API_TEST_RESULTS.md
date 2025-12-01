# InvoiceNinja API Test Results

**Date:** December 1, 2025  
**Instance:** https://invoiceninja5.dix30.be  
**API Version:** v1  

---

## ✅ Connection Test: SUCCESSFUL

### API Token
- **Token Name:** taiga-integration
- **Token:** `5qspQh0zPPLkplpheH3oHtKDBu4gNc6El7stgDUdq9Ah4lMKxh6KrK8CdW7rD8WF`
- **Status:** Valid and active

### Company Information
- **Company Name:** Black Box Studio bvba/srl
- **User:** Accounting Black Box Studio
- **Email:** accounting@blackboxstudio.be
- **Country:** Belgium (BE)
- **VAT Enabled:** Yes (21% standard rate)
- **Currency:** EUR
- **Task Tracking:** Enabled (invoice_task_timelog: true)
- **Billable Tasks:** Enabled (allow_billable_task_items: true)

---

## 📦 Existing Products/Services (Sample)

Your InvoiceNinja already has products configured:

| Product Key | Description | Cost (EUR) |
|-------------|-------------|------------|
| Photographie | Prestation Photographe, matériel (éclairage et prise de vue) /jour | €800.00 |
| Pre-Production | briefing, vergadering, allerlei prep | €150.00 |
| Preparation | réunions préparatoires | €250.00 |
| assitant | Prestation Plateau | €250.00 |
| assitant plateau | Prestation Plateau - Still Life | €350.00 |
| Make-Up | | €350.00 |
| GreenKey | Fourniture Fond GreenKey (-50%) | €75.00 |
| decor | Fabrication de l'aile d'avion (matériel + peinture) | €200.00 |
| catering | | €30.00 |
| + frais | achats | €42.00 |

**Recommendation:** Add more products from the comprehensive list we created earlier (200+ services covering all your activities).

---

## 👥 Existing Clients (Sample)

| Client Name | Balance | Paid to Date |
|-------------|---------|--------------|
| These Days Y&R | €0.00 | €0.00 |
| Publicis | €0.00 | €0.00 |
| Art Direction Goossens & Van Hoof | €0.00 | €0.00 |
| Design Vlaanderen | €0.00 | €0.00 |
| Goodwill M1G | €0.00 | €0.00 |

**Note:** All clients show zero balance (likely paid up or no recent activity).

---

## 🔧 Configuration Summary

### Email Settings
- **SMTP Host:** ssl0.ovh.net
- **SMTP Port:** 587
- **SMTP Encryption:** TLS
- **From Name:** Accounting @ Black Box Studio Brussels
- **From Email:** accounting@blackboxstudio.be
- **Status:** ✅ Configured

### Tax Settings
- **Enabled Tax Rates:** 2
- **EU VAT:** Belgium (21% standard, 6% reduced)
- **Tax Calculation:** Manual (calculate_taxes: false)

### Invoicing Features
- **Invoice Task Hours:** Enabled
- **Invoice Task Timelog:** Enabled
- **Invoice Task Project:** Disabled
- **Task Project Header:** Enabled
- **Markdown Support:** Enabled
- **Auto-archive on Cancel:** Disabled

### Integration Settings
- **Webhooks:** Available (need to configure)
- **API Access:** Full access enabled
- **QuickBooks:** Token present but inactive
- **E-Invoice:** Disabled (can enable for PEPPOL)

---

## 🎯 Ready for Integration

Your InvoiceNinja instance is **ready for Taiga integration**!

### Next Steps:

1. **Configure Webhooks in InvoiceNinja**
   ```
   URL: https://your-middleware.com/webhook/invoice
   Events: invoice.created, invoice.sent, invoice.paid
   ```

2. **Add Custom Fields for Taiga Integration**
   - Client Custom Field: `taiga_project_id`
   - Invoice Custom Field: `taiga_task_id`
   - Invoice Custom Field: `taiga_time_entry_id`

3. **Import Additional Products**
   - Use the 200+ service list we created
   - Organize by category (Photography, Video, Web Dev, etc.)
   - Set default rates and tax rates

4. **Configure PEPPOL (Optional)**
   - Register PEPPOL ID for B2G invoicing
   - Enable e-invoice in settings
   - Set up access point provider (Storecove recommended)

5. **Deploy Middleware**
   - Use the Python Flask code from integration guide
   - Configure environment variables
   - Set up on Docker or VPS

6. **Install Time Tracker App**
   - Once Taiga is installed
   - Configure with both Taiga and InvoiceNinja URLs
   - Start tracking billable hours

---

## 📊 API Endpoints Tested

| Endpoint | Method | Status | Response |
|----------|--------|--------|----------|
| `/api/v1/ping` | GET | ✅ 200 OK | Company and user info |
| `/api/v1/companies` | GET | ✅ 200 OK | Full company details |
| `/api/v1/products` | GET | ✅ 200 OK | 10 products returned |
| `/api/v1/clients` | GET | ✅ 200 OK | 5 clients returned |

### Sample API Calls

#### Test Connection
```bash
curl -X GET "https://invoiceninja5.dix30.be/api/v1/ping" \
  -H "X-API-Token: 5qspQh0zPPLkplpheH3oHtKDBu4gNc6El7stgDUdq9Ah4lMKxh6KrK8CdW7rD8WF"
```

#### Create Invoice (Example)
```bash
curl -X POST "https://invoiceninja5.dix30.be/api/v1/invoices" \
  -H "X-API-Token: 5qspQh0zPPLkplpheH3oHtKDBu4gNc6El7stgDUdq9Ah4lMKxh6KrK8CdW7rD8WF" \
  -H "Content-Type: application/json" \
  -d '{
    "client_id": "client_id_here",
    "line_items": [{
      "product_key": "Photographie",
      "notes": "Food photography session - 8 hours",
      "cost": 800,
      "quantity": 1,
      "tax_rate1": 21
    }]
  }'
```

#### Get Tasks (for time tracking)
```bash
curl -X GET "https://invoiceninja5.dix30.be/api/v1/tasks" \
  -H "X-API-Token: 5qspQh0zPPLkplpheH3oHtKDBu4gNc6El7stgDUdq9Ah4lMKxh6KrK8CdW7rD8WF"
```

---

## 🔐 Security Recommendations

1. **Store Token Securely**
   - Never commit to Git
   - Use environment variables
   - Rotate every 90 days

2. **Enable HTTPS Only**
   - ✅ Already enabled (invoiceninja5.dix30.be uses SSL)

3. **Restrict Token Permissions**
   - Check token has only required scopes
   - Create separate tokens for different integrations

4. **Monitor API Usage**
   - Check logs regularly
   - Set up alerts for failed requests

5. **Backup Strategy**
   - InvoiceNinja has export functionality
   - Schedule regular backups
   - Test restore procedures

---

## 📚 Related Documentation

- **Taiga-InvoiceNinja Integration:** `TAIGA_INVOICENINJA_INTEGRATION.md`
- **Time Tracker App Spec:** `TAIGA_TIMETRACKER_APP.md`
- **PEPPOL Integration:** `INVOICENINJA_PEPPOL_INTEGRATION.md`
- **Billable Services List:** `untitled:Untitled-1`

---

## ✅ Summary

**Status:** All systems operational!

- ✅ API connection verified
- ✅ Company details retrieved
- ✅ Products configured
- ✅ Clients active
- ✅ Email settings configured
- ✅ Task tracking enabled
- ✅ Ready for webhook integration

**You can now proceed with:**
1. Finishing Taiga installation on YunoHost
2. Building/deploying the integration middleware
3. Importing additional products/services
4. Setting up the time tracker desktop app

---

**Questions or issues?** Everything is working perfectly! Ready to integrate once Taiga installation completes.
