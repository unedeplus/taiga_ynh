# InvoiceNinja PEPPOL Integration Guide

**Complete setup guide for PEPPOL e-invoicing with InvoiceNinja**

---

## What is PEPPOL?

**PEPPOL** (Pan-European Public Procurement On-Line) is an international standard for electronic invoicing and procurement. It enables businesses to send and receive invoices electronically across borders through a secure network of access points.

### Key Benefits

✅ **Mandatory Compliance**: Required for B2G (Business-to-Government) transactions in EU countries  
✅ **Automated Processing**: Direct integration into accounting systems  
✅ **Faster Payments**: Reduced processing time from weeks to days  
✅ **Cost Reduction**: Eliminates paper, printing, and postal costs  
✅ **Error Reduction**: Structured data format reduces manual entry errors  
✅ **International Reach**: Works across 30+ countries in Europe and beyond  

### PEPPOL Network Overview

```
┌─────────────────────────────────────────────────────────┐
│                     PEPPOL Network                       │
├─────────────────────────────────────────────────────────┤
│                                                          │
│   Your Business          Access Point        Recipient  │
│   ┌──────────┐          ┌──────────┐       ┌─────────┐ │
│   │Invoice   │  UBL/    │ PEPPOL   │ SML/  │Customer │ │
│   │Ninja     │─────────▶│ Access   │──────▶│Accounting│ │
│   │          │  CII     │ Point    │ SMP   │ System  │ │
│   └──────────┘          └──────────┘       └─────────┘ │
│                                                          │
│   Certified Provider    Routing & Validation            │
└─────────────────────────────────────────────────────────┘
```

---

## Prerequisites

### 1. PEPPOL ID (Participant ID)

Every business needs a unique PEPPOL ID format:
```
[ISO 6523 ICD]::[Identifier]

Examples:
0088:1234567890123      (GLN - Global Location Number)
0208:123456789          (Belgian VAT number)
9925:BE0123456789       (Belgian VAT via OpenPEPPOL)
0002:FR12345678901      (French SIREN)
9956:0999999999         (Belgian Enterprise Number)
```

**How to get your PEPPOL ID:**
- In Belgium: Use your VAT number with scheme `0208` or enterprise number with `9956`
- EU: Use your national VAT/tax ID with appropriate scheme code
- Check: [ISO 6523 code list](https://docs.peppol.eu/poacc/billing/3.0/codelist/ICD/)

### 2. Company Information

Required for PEPPOL registration:
- Legal business name
- VAT/Tax identification number
- Official business address
- Contact email and phone
- Bank account details (IBAN)
- Legal representative information

### 3. InvoiceNinja Instance

- InvoiceNinja v5.x self-hosted: **https://invoiceninja5.dix30.be**
- Admin access to settings
- Valid SSL certificate (required for PEPPOL)
- Stable public URL

---

## PEPPOL Access Point Providers

InvoiceNinja doesn't have built-in PEPPOL support, so you need a **PEPPOL Access Point Provider** (certified intermediary).

### Recommended Providers

#### 1. **Storecove** (Recommended for InvoiceNinja)
- **Website**: https://www.storecove.com
- **Pricing**: Pay-per-document (~€0.10-0.30 per invoice)
- **Integration**: REST API (easy to integrate)
- **Coverage**: Worldwide PEPPOL + direct networks
- **Features**: 
  - Invoice validation before sending
  - Automatic routing
  - Delivery tracking
  - API-first design (perfect for InvoiceNinja)
  - No minimum volume

#### 2. **Pagero**
- **Website**: https://www.pagero.com
- **Pricing**: Monthly subscription + per-document fees
- **Integration**: REST API + SFTP
- **Coverage**: Global (60+ countries)
- **Features**: 
  - Multi-format support (PEPPOL, e-FFF, Facturae, etc.)
  - Compliance management
  - Enterprise-grade

#### 3. **Tradeshift**
- **Website**: https://tradeshift.com
- **Pricing**: Freemium model (free tier available)
- **Integration**: REST API
- **Coverage**: Global
- **Features**: 
  - Free for receiving invoices
  - Buyer-supplier network
  - Supply chain platform

#### 4. **Unimaze (Belgium-specific)**
- **Website**: https://www.unimaze.com
- **Pricing**: €5-15/month + per-document
- **Integration**: Web portal + API
- **Coverage**: Belgium, EU
- **Features**: 
  - Belgian market specialist
  - SME-friendly pricing
  - Local support

#### 5. **Zoomit (Belgium-specific)**
- **Website**: https://www.zoomit.be
- **Pricing**: Subscription-based
- **Integration**: Web portal + API
- **Coverage**: Belgium, EU
- **Features**: 
  - Trusted third party
  - Archive service included
  - Belgian compliance expert

### Comparison Table

| Provider    | Setup Cost | Per Invoice | API Quality | Best For |
|-------------|------------|-------------|-------------|----------|
| Storecove   | Free       | €0.10-0.30  | ⭐⭐⭐⭐⭐   | API integration |
| Pagero      | €500+      | €0.20-0.50  | ⭐⭐⭐⭐     | Enterprise |
| Tradeshift  | Free       | €0.15-0.40  | ⭐⭐⭐⭐     | High volume |
| Unimaze     | €50        | €0.15-0.25  | ⭐⭐⭐       | Belgian SME |
| Zoomit      | €100       | €0.20-0.35  | ⭐⭐⭐       | Belgian compliance |

---

## Integration Architecture

### Option A: Direct API Integration (Recommended)

```
┌──────────────────────────────────────────────────────────┐
│                 InvoiceNinja Workflow                     │
├──────────────────────────────────────────────────────────┤
│                                                           │
│  1. Create Invoice in InvoiceNinja                       │
│  2. Mark as "Sent" → Trigger Webhook                     │
│  3. Middleware captures webhook                          │
│  4. Convert Invoice to UBL 2.1 format                    │
│  5. Send to PEPPOL Access Point API                      │
│  6. Receive delivery confirmation                        │
│  7. Update InvoiceNinja with PEPPOL ID                   │
│                                                           │
└──────────────────────────────────────────────────────────┘
```

**Components:**
- InvoiceNinja webhooks
- Python/PHP middleware service
- PEPPOL Access Point API (e.g., Storecove)
- UBL 2.1 converter

### Option B: Manual Export/Import

```
┌──────────────────────────────────────────────────────────┐
│              Manual PEPPOL Workflow                       │
├──────────────────────────────────────────────────────────┤
│                                                           │
│  1. Create Invoice in InvoiceNinja                       │
│  2. Export as UBL XML (via custom template)              │
│  3. Upload to PEPPOL provider portal                     │
│  4. Provider validates and sends via PEPPOL              │
│  5. Manually mark as sent in InvoiceNinja                │
│                                                           │
└──────────────────────────────────────────────────────────┘
```

**Best for:** Low volume, testing, or no development resources

---

## Step-by-Step Setup Guide

### Step 1: Register with PEPPOL Access Point Provider

**Using Storecove (Example):**

1. **Sign up**:
   ```bash
   Visit: https://www.storecove.com/signup
   ```

2. **Register your PEPPOL ID**:
   - Navigate to: Settings → PEPPOL Registration
   - Enter your PEPPOL ID (e.g., `0208:BE0123456789`)
   - Provide company details
   - Upload business registration documents
   - Wait for approval (1-3 business days)

3. **Get API credentials**:
   - Navigate to: Settings → API Keys
   - Generate new API key
   - Save securely: `sk_live_xxxxxxxxxxxxxxxxxxxxx`

### Step 2: Configure InvoiceNinja

#### 2.1 Enable Webhooks

```bash
# Log into InvoiceNinja admin
https://invoiceninja5.dix30.be/settings/account_management

# Navigate to: Settings → Webhooks
# Create new webhook:
URL: https://your-middleware.com/webhook/invoice
Events: invoice.sent, invoice.updated
Format: JSON
```

#### 2.2 Add Custom Invoice Fields

```bash
# Navigate to: Settings → Custom Fields → Invoice

# Add PEPPOL-specific fields:
Field Name: PEPPOL ID
Field Type: Text
Show on Invoice: Yes

Field Name: PEPPOL Scheme
Field Type: Dropdown
Options: 0088,0208,9925,9956
Show on Invoice: No

Field Name: PEPPOL Status
Field Type: Text
Show on Invoice: No
```

#### 2.3 Update Invoice Template

Add PEPPOL ID field to email template:
```html
<!-- In Settings → Email Templates → Invoice Email -->
<p>PEPPOL ID: $client.custom_value1</p>
```

### Step 3: Create UBL Converter Middleware

#### 3.1 Project Structure

```bash
peppol-middleware/
├── main.py                  # Flask webhook receiver
├── ubl_converter.py         # InvoiceNinja → UBL converter
├── storecove_client.py      # PEPPOL Access Point API
├── config.py                # Configuration
├── requirements.txt
└── docker-compose.yml       # Optional: Docker deployment
```

#### 3.2 UBL Converter (`ubl_converter.py`)

```python
from lxml import etree
from datetime import datetime
from typing import Dict

class UBLConverter:
    """Convert InvoiceNinja invoice to UBL 2.1 format"""
    
    NAMESPACES = {
        'cac': 'urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2',
        'cbc': 'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2',
        'ccts': 'urn:un:unece:uncefact:documentation:2',
        'qdt': 'urn:oasis:names:specification:ubl:schema:xsd:QualifiedDataTypes-2',
        'udt': 'urn:oasis:names:specification:ubl:schema:xsd:UnqualifiedDataTypes-2'
    }
    
    def convert(self, invoice_data: Dict) -> str:
        """Convert InvoiceNinja invoice to UBL XML"""
        
        # Create root element
        root = etree.Element(
            '{urn:oasis:names:specification:ubl:schema:xsd:Invoice-2}Invoice',
            nsmap={
                None: 'urn:oasis:names:specification:ubl:schema:xsd:Invoice-2',
                **self.NAMESPACES
            }
        )
        
        # UBL Version ID
        self._add_element(root, 'cbc:UBLVersionID', '2.1')
        self._add_element(root, 'cbc:CustomizationID', 
                         'urn:cen.eu:en16931:2017#compliant#urn:fdc:peppol.eu:2017:poacc:billing:3.0')
        self._add_element(root, 'cbc:ProfileID', 'urn:fdc:peppol.eu:2017:poacc:billing:01:1.0')
        
        # Invoice identification
        self._add_element(root, 'cbc:ID', invoice_data['number'])
        self._add_element(root, 'cbc:IssueDate', 
                         datetime.fromisoformat(invoice_data['date']).strftime('%Y-%m-%d'))
        
        if invoice_data.get('due_date'):
            self._add_element(root, 'cbc:DueDate', 
                             datetime.fromisoformat(invoice_data['due_date']).strftime('%Y-%m-%d'))
        
        # Invoice type code (380 = Commercial invoice)
        self._add_element(root, 'cbc:InvoiceTypeCode', '380')
        
        # Document currency
        self._add_element(root, 'cbc:DocumentCurrencyCode', invoice_data.get('currency', 'EUR'))
        
        # Supplier (your company)
        self._add_supplier_party(root, invoice_data['company'])
        
        # Customer
        self._add_customer_party(root, invoice_data['client'])
        
        # Payment means
        self._add_payment_means(root, invoice_data)
        
        # Tax total
        self._add_tax_total(root, invoice_data)
        
        # Monetary total
        self._add_monetary_total(root, invoice_data)
        
        # Invoice lines
        for line in invoice_data['line_items']:
            self._add_invoice_line(root, line, invoice_data)
        
        # Convert to string
        return etree.tostring(
            root, 
            pretty_print=True, 
            xml_declaration=True, 
            encoding='UTF-8'
        ).decode('utf-8')
    
    def _add_element(self, parent, tag: str, value: str):
        """Add child element with namespace"""
        ns, local = tag.split(':')
        elem = etree.SubElement(parent, f'{{{self.NAMESPACES[ns]}}}{local}')
        elem.text = str(value)
        return elem
    
    def _add_supplier_party(self, root, company: Dict):
        """Add AccountingSupplierParty"""
        supplier = etree.SubElement(
            root, 
            f'{{{self.NAMESPACES["cac"]}}}AccountingSupplierParty'
        )
        
        party = etree.SubElement(supplier, f'{{{self.NAMESPACES["cac"]}}}Party')
        
        # PEPPOL Endpoint ID
        endpoint = self._add_element(party, 'cbc:EndpointID', company['peppol_id'])
        endpoint.set('schemeID', company.get('peppol_scheme', '0208'))
        
        # Party identification
        party_id = etree.SubElement(party, f'{{{self.NAMESPACES["cac"]}}}PartyIdentification')
        self._add_element(party_id, 'cbc:ID', company.get('vat_number', ''))
        
        # Party name
        party_name = etree.SubElement(party, f'{{{self.NAMESPACES["cac"]}}}PartyName')
        self._add_element(party_name, 'cbc:Name', company['name'])
        
        # Postal address
        address = etree.SubElement(party, f'{{{self.NAMESPACES["cac"]}}}PostalAddress')
        self._add_element(address, 'cbc:StreetName', company.get('address1', ''))
        if company.get('address2'):
            self._add_element(address, 'cbc:AdditionalStreetName', company['address2'])
        self._add_element(address, 'cbc:CityName', company.get('city', ''))
        self._add_element(address, 'cbc:PostalZone', company.get('postal_code', ''))
        
        country = etree.SubElement(address, f'{{{self.NAMESPACES["cac"]}}}Country')
        self._add_element(country, 'cbc:IdentificationCode', company.get('country', 'BE'))
        
        # Party tax scheme (VAT)
        tax_scheme_node = etree.SubElement(party, f'{{{self.NAMESPACES["cac"]}}}PartyTaxScheme')
        self._add_element(tax_scheme_node, 'cbc:CompanyID', company.get('vat_number', ''))
        
        tax_scheme = etree.SubElement(tax_scheme_node, f'{{{self.NAMESPACES["cac"]}}}TaxScheme')
        self._add_element(tax_scheme, 'cbc:ID', 'VAT')
        
        # Legal entity
        legal = etree.SubElement(party, f'{{{self.NAMESPACES["cac"]}}}PartyLegalEntity')
        self._add_element(legal, 'cbc:RegistrationName', company['name'])
        self._add_element(legal, 'cbc:CompanyID', company.get('id_number', ''))
        
        # Contact
        if company.get('email') or company.get('phone'):
            contact = etree.SubElement(party, f'{{{self.NAMESPACES["cac"]}}}Contact')
            if company.get('email'):
                self._add_element(contact, 'cbc:ElectronicMail', company['email'])
            if company.get('phone'):
                self._add_element(contact, 'cbc:Telephone', company['phone'])
    
    def _add_customer_party(self, root, client: Dict):
        """Add AccountingCustomerParty"""
        customer = etree.SubElement(
            root, 
            f'{{{self.NAMESPACES["cac"]}}}AccountingCustomerParty'
        )
        
        party = etree.SubElement(customer, f'{{{self.NAMESPACES["cac"]}}}Party')
        
        # PEPPOL Endpoint ID (if customer has one)
        if client.get('peppol_id'):
            endpoint = self._add_element(party, 'cbc:EndpointID', client['peppol_id'])
            endpoint.set('schemeID', client.get('peppol_scheme', '0208'))
        else:
            # Fallback: use email
            endpoint = self._add_element(party, 'cbc:EndpointID', client.get('email', 'unknown@unknown.com'))
            endpoint.set('schemeID', 'EM')  # Email scheme
        
        # Party name
        party_name = etree.SubElement(party, f'{{{self.NAMESPACES["cac"]}}}PartyName')
        self._add_element(party_name, 'cbc:Name', client['name'])
        
        # Postal address
        address = etree.SubElement(party, f'{{{self.NAMESPACES["cac"]}}}PostalAddress')
        self._add_element(address, 'cbc:StreetName', client.get('address1', ''))
        if client.get('address2'):
            self._add_element(address, 'cbc:AdditionalStreetName', client['address2'])
        self._add_element(address, 'cbc:CityName', client.get('city', ''))
        self._add_element(address, 'cbc:PostalZone', client.get('postal_code', ''))
        
        country = etree.SubElement(address, f'{{{self.NAMESPACES["cac"]}}}Country')
        self._add_element(country, 'cbc:IdentificationCode', client.get('country', 'BE'))
        
        # Party legal entity
        legal = etree.SubElement(party, f'{{{self.NAMESPACES["cac"]}}}PartyLegalEntity')
        self._add_element(legal, 'cbc:RegistrationName', client['name'])
        if client.get('vat_number'):
            self._add_element(legal, 'cbc:CompanyID', client['vat_number'])
    
    def _add_payment_means(self, root, invoice: Dict):
        """Add PaymentMeans"""
        payment = etree.SubElement(root, f'{{{self.NAMESPACES["cac"]}}}PaymentMeans')
        
        # Payment means code (30 = Credit transfer, 58 = SEPA)
        self._add_element(payment, 'cbc:PaymentMeansCode', '30')
        
        # Payment ID (invoice number)
        self._add_element(payment, 'cbc:PaymentID', invoice['number'])
        
        # Payee financial account (your bank account)
        if invoice.get('company', {}).get('iban'):
            financial = etree.SubElement(payment, f'{{{self.NAMESPACES["cac"]}}}PayeeFinancialAccount')
            self._add_element(financial, 'cbc:ID', invoice['company']['iban'])
            
            if invoice['company'].get('bank_name'):
                bank = etree.SubElement(financial, f'{{{self.NAMESPACES["cac"]}}}FinancialInstitutionBranch')
                self._add_element(bank, 'cbc:ID', invoice['company'].get('bic', 'NOTPROVIDED'))
    
    def _add_tax_total(self, root, invoice: Dict):
        """Add TaxTotal"""
        tax_total_node = etree.SubElement(root, f'{{{self.NAMESPACES["cac"]}}}TaxTotal')
        
        # Total tax amount
        tax_amount = self._add_element(
            tax_total_node, 
            'cbc:TaxAmount', 
            f"{invoice.get('total_taxes', 0):.2f}"
        )
        tax_amount.set('currencyID', invoice.get('currency', 'EUR'))
        
        # Tax subtotals (group by VAT rate)
        tax_rates = {}
        for line in invoice.get('line_items', []):
            rate = line.get('tax_rate1', 21.0)
            if rate not in tax_rates:
                tax_rates[rate] = {
                    'taxable_amount': 0,
                    'tax_amount': 0
                }
            line_total = line['quantity'] * line['cost']
            tax_rates[rate]['taxable_amount'] += line_total
            tax_rates[rate]['tax_amount'] += line_total * (rate / 100)
        
        for rate, amounts in tax_rates.items():
            subtotal = etree.SubElement(tax_total_node, f'{{{self.NAMESPACES["cac"]}}}TaxSubtotal')
            
            taxable = self._add_element(subtotal, 'cbc:TaxableAmount', f"{amounts['taxable_amount']:.2f}")
            taxable.set('currencyID', invoice.get('currency', 'EUR'))
            
            tax_amt = self._add_element(subtotal, 'cbc:TaxAmount', f"{amounts['tax_amount']:.2f}")
            tax_amt.set('currencyID', invoice.get('currency', 'EUR'))
            
            category = etree.SubElement(subtotal, f'{{{self.NAMESPACES["cac"]}}}TaxCategory')
            self._add_element(category, 'cbc:ID', 'S')  # Standard rate
            self._add_element(category, 'cbc:Percent', f"{rate:.2f}")
            
            scheme = etree.SubElement(category, f'{{{self.NAMESPACES["cac"]}}}TaxScheme')
            self._add_element(scheme, 'cbc:ID', 'VAT')
    
    def _add_monetary_total(self, root, invoice: Dict):
        """Add LegalMonetaryTotal"""
        monetary = etree.SubElement(root, f'{{{self.NAMESPACES["cac"]}}}LegalMonetaryTotal')
        
        currency = invoice.get('currency', 'EUR')
        
        # Line extension amount (subtotal without tax)
        line_ext = self._add_element(
            monetary, 
            'cbc:LineExtensionAmount', 
            f"{invoice.get('subtotal', 0):.2f}"
        )
        line_ext.set('currencyID', currency)
        
        # Tax exclusive amount
        tax_excl = self._add_element(
            monetary, 
            'cbc:TaxExclusiveAmount', 
            f"{invoice.get('subtotal', 0):.2f}"
        )
        tax_excl.set('currencyID', currency)
        
        # Tax inclusive amount (total with tax)
        tax_incl = self._add_element(
            monetary, 
            'cbc:TaxInclusiveAmount', 
            f"{invoice.get('total', 0):.2f}"
        )
        tax_incl.set('currencyID', currency)
        
        # Payable amount
        payable = self._add_element(
            monetary, 
            'cbc:PayableAmount', 
            f"{invoice.get('balance', invoice.get('total', 0)):.2f}"
        )
        payable.set('currencyID', currency)
    
    def _add_invoice_line(self, root, line: Dict, invoice: Dict):
        """Add InvoiceLine"""
        line_node = etree.SubElement(root, f'{{{self.NAMESPACES["cac"]}}}InvoiceLine')
        
        # Line ID
        self._add_element(line_node, 'cbc:ID', str(line.get('id', 1)))
        
        # Invoiced quantity
        quantity = self._add_element(
            line_node, 
            'cbc:InvoicedQuantity', 
            str(line.get('quantity', 1))
        )
        quantity.set('unitCode', 'HUR')  # Hour (or use C62 for unit)
        
        # Line extension amount
        line_total = line['quantity'] * line['cost']
        line_ext = self._add_element(line_node, 'cbc:LineExtensionAmount', f"{line_total:.2f}")
        line_ext.set('currencyID', invoice.get('currency', 'EUR'))
        
        # Item
        item = etree.SubElement(line_node, f'{{{self.NAMESPACES["cac"]}}}Item')
        self._add_element(item, 'cbc:Name', line.get('product_key', line.get('notes', 'Service')))
        
        if line.get('notes'):
            self._add_element(item, 'cbc:Description', line['notes'])
        
        # Tax category
        tax_cat = etree.SubElement(item, f'{{{self.NAMESPACES["cac"]}}}ClassifiedTaxCategory')
        self._add_element(tax_cat, 'cbc:ID', 'S')
        self._add_element(tax_cat, 'cbc:Percent', str(line.get('tax_rate1', 21.0)))
        
        tax_scheme = etree.SubElement(tax_cat, f'{{{self.NAMESPACES["cac"]}}}TaxScheme')
        self._add_element(tax_scheme, 'cbc:ID', 'VAT')
        
        # Price
        price_node = etree.SubElement(line_node, f'{{{self.NAMESPACES["cac"]}}}Price')
        price_amt = self._add_element(price_node, 'cbc:PriceAmount', f"{line['cost']:.2f}")
        price_amt.set('currencyID', invoice.get('currency', 'EUR'))
```

#### 3.3 Storecove API Client (`storecove_client.py`)

```python
import requests
from typing import Dict, Optional

class StorecoveClient:
    """PEPPOL Access Point API client"""
    
    BASE_URL = "https://api.storecove.com/api/v2"
    
    def __init__(self, api_key: str):
        self.api_key = api_key
        self.session = requests.Session()
        self.session.headers.update({
            'Authorization': f'Bearer {api_key}',
            'Content-Type': 'application/json'
        })
    
    def send_invoice(self, ubl_xml: str, recipient_peppol_id: str, 
                     recipient_scheme: str = '0208') -> Dict:
        """Send UBL invoice via PEPPOL"""
        
        payload = {
            'legalEntityId': 1,  # Your registered legal entity ID
            'routing': {
                'eIdentifiers': [{
                    'scheme': recipient_scheme,
                    'id': recipient_peppol_id
                }]
            },
            'document': {
                'documentType': 'invoice',
                'rawDocumentData': {
                    'document': ubl_xml,
                    'parse': True,
                    'parseStrategy': 'ubl'
                }
            }
        }
        
        response = self.session.post(
            f'{self.BASE_URL}/shop_account_requests/invoice_submissions',
            json=payload
        )
        response.raise_for_status()
        return response.json()
    
    def get_delivery_status(self, guid: str) -> Dict:
        """Check delivery status of sent invoice"""
        response = self.session.get(
            f'{self.BASE_URL}/shop_account_requests/{guid}'
        )
        response.raise_for_status()
        return response.json()
    
    def lookup_peppol_id(self, identifier: str, scheme: str = '0208') -> Optional[Dict]:
        """Look up if recipient is registered on PEPPOL network"""
        response = self.session.get(
            f'{self.BASE_URL}/peppol_directory',
            params={
                'identifier': identifier,
                'scheme': scheme
            }
        )
        
        if response.status_code == 200:
            return response.json()
        return None
```

#### 3.4 Flask Webhook Handler (`main.py`)

```python
from flask import Flask, request, jsonify
import requests
from ubl_converter import UBLConverter
from storecove_client import StorecoveClient
import os

app = Flask(__name__)

# Configuration
INVOICENINJA_URL = os.getenv('INVOICENINJA_URL', 'https://invoiceninja5.dix30.be')
INVOICENINJA_TOKEN = os.getenv('INVOICENINJA_TOKEN')
STORECOVE_API_KEY = os.getenv('STORECOVE_API_KEY')

# Clients
ubl_converter = UBLConverter()
peppol_client = StorecoveClient(STORECOVE_API_KEY)

@app.route('/webhook/invoice', methods=['POST'])
def handle_invoice_webhook():
    """Handle InvoiceNinja webhook for invoice.sent event"""
    
    data = request.json
    
    # Only process sent invoices
    if data.get('event') != 'invoice.sent':
        return jsonify({'status': 'ignored'}), 200
    
    invoice_id = data.get('invoice_id')
    
    # Fetch full invoice data
    invoice = fetch_invoice_from_ninja(invoice_id)
    
    # Check if client has PEPPOL ID
    client_peppol_id = invoice['client'].get('custom_value1')  # Assuming stored in custom field
    
    if not client_peppol_id:
        print(f"Invoice {invoice['number']}: Client has no PEPPOL ID, skipping")
        return jsonify({'status': 'no_peppol_id'}), 200
    
    # Convert to UBL
    try:
        ubl_xml = ubl_converter.convert(invoice)
    except Exception as e:
        print(f"UBL conversion failed: {e}")
        return jsonify({'status': 'error', 'message': str(e)}), 500
    
    # Send via PEPPOL
    try:
        result = peppol_client.send_invoice(
            ubl_xml=ubl_xml,
            recipient_peppol_id=client_peppol_id,
            recipient_scheme=invoice['client'].get('custom_value2', '0208')
        )
        
        # Update invoice with PEPPOL tracking ID
        update_invoice_ninja(
            invoice_id, 
            custom_value='peppol_guid', 
            value=result['guid']
        )
        
        print(f"Invoice {invoice['number']} sent via PEPPOL. GUID: {result['guid']}")
        
        return jsonify({
            'status': 'success',
            'peppol_guid': result['guid']
        }), 200
        
    except Exception as e:
        print(f"PEPPOL send failed: {e}")
        return jsonify({'status': 'error', 'message': str(e)}), 500


def fetch_invoice_from_ninja(invoice_id: str) -> dict:
    """Fetch invoice details from InvoiceNinja API"""
    headers = {
        'X-API-Token': INVOICENINJA_TOKEN,
        'Content-Type': 'application/json'
    }
    
    response = requests.get(
        f'{INVOICENINJA_URL}/api/v1/invoices/{invoice_id}',
        headers=headers
    )
    response.raise_for_status()
    return response.json()['data']


def update_invoice_ninja(invoice_id: str, custom_value: str, value: str):
    """Update invoice in InvoiceNinja"""
    headers = {
        'X-API-Token': INVOICENINJA_TOKEN,
        'Content-Type': 'application/json'
    }
    
    payload = {
        'custom_value3': value  # Store PEPPOL GUID
    }
    
    response = requests.put(
        f'{INVOICENINJA_URL}/api/v1/invoices/{invoice_id}',
        headers=headers,
        json=payload
    )
    response.raise_for_status()


@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({'status': 'healthy'}), 200


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
```

#### 3.5 Requirements (`requirements.txt`)

```txt
Flask==3.0.0
requests==2.31.0
lxml==4.9.3
python-dotenv==1.0.0
```

#### 3.6 Docker Deployment (`docker-compose.yml`)

```yaml
version: '3.8'

services:
  peppol-middleware:
    build: .
    container_name: peppol-middleware
    ports:
      - "5000:5000"
    environment:
      - INVOICENINJA_URL=https://invoiceninja5.dix30.be
      - INVOICENINJA_TOKEN=${INVOICENINJA_TOKEN}
      - STORECOVE_API_KEY=${STORECOVE_API_KEY}
    restart: unless-stopped
    volumes:
      - ./logs:/app/logs
```

### Step 4: Test Integration

#### 4.1 Test UBL Conversion

```python
# test_ubl.py
from ubl_converter import UBLConverter

test_invoice = {
    'number': 'INV-2025-001',
    'date': '2025-12-01',
    'due_date': '2025-12-31',
    'currency': 'EUR',
    'subtotal': 1000.00,
    'total_taxes': 210.00,
    'total': 1210.00,
    'balance': 1210.00,
    'company': {
        'name': 'Your Company SPRL',
        'peppol_id': 'BE0123456789',
        'peppol_scheme': '0208',
        'vat_number': 'BE0123456789',
        'address1': 'Rue Example 123',
        'city': 'Brussels',
        'postal_code': '1000',
        'country': 'BE',
        'email': 'info@yourcompany.be',
        'iban': 'BE68539007547034',
        'bic': 'GKCCBEBB'
    },
    'client': {
        'name': 'Client Company SA',
        'peppol_id': 'BE0987654321',
        'peppol_scheme': '0208',
        'vat_number': 'BE0987654321',
        'address1': 'Avenue Test 456',
        'city': 'Antwerp',
        'postal_code': '2000',
        'country': 'BE'
    },
    'line_items': [
        {
            'id': 1,
            'product_key': 'WEB-DEV-001',
            'notes': 'Website development - 10 hours',
            'quantity': 10,
            'cost': 100.00,
            'tax_rate1': 21.0
        }
    ]
}

converter = UBLConverter()
ubl_xml = converter.convert(test_invoice)

# Save to file
with open('test_invoice.xml', 'w', encoding='utf-8') as f:
    f.write(ubl_xml)

print("UBL XML generated: test_invoice.xml")
```

#### 4.2 Validate UBL XML

Use online validator:
- **PEPPOL Validator**: https://test-notier.eu/peppol-bis-billing-3-0-validator/
- Upload your `test_invoice.xml`
- Check for errors

#### 4.3 Test PEPPOL Delivery

```python
# test_send.py
from storecove_client import StorecoveClient

client = StorecoveClient('your_api_key_here')

# Load test UBL
with open('test_invoice.xml', 'r') as f:
    ubl_xml = f.read()

# Send to test recipient
result = client.send_invoice(
    ubl_xml=ubl_xml,
    recipient_peppol_id='BE0987654321',
    recipient_scheme='0208'
)

print(f"Sent! GUID: {result['guid']}")

# Check status
import time
time.sleep(10)
status = client.get_delivery_status(result['guid'])
print(f"Status: {status}")
```

---

## Manual Workflow (No Code)

If you don't want to develop middleware:

### 1. Export Invoice as PDF with Structured Data

Create custom invoice template in InvoiceNinja with all PEPPOL-required fields.

### 2. Use PEPPOL Provider Web Portal

1. Log into Storecove/Unimaze/Zoomit portal
2. Click "Send Invoice"
3. Fill in recipient PEPPOL ID
4. Upload PDF or manually enter invoice data
5. Click "Send"
6. Copy tracking ID back to InvoiceNinja notes

### 3. Mark as Sent in InvoiceNinja

Manually update invoice status.

---

## Cost Breakdown

### Setup Costs (One-time)

| Item | Cost |
|------|------|
| PEPPOL Registration (via provider) | €0-500 |
| Development (if building middleware) | €2,000-5,000 |
| Testing & Validation | €500-1,000 |
| **Total** | **€2,500-6,500** |

### Ongoing Costs (Monthly)

| Item | Cost |
|------|------|
| Storecove subscription | €0 (pay-per-use) |
| Per invoice fee | €0.10-0.30 |
| Example: 50 invoices/month | €5-15/month |
| Middleware hosting (optional) | €5-20/month |
| **Total (50 invoices)** | **€10-35/month** |

---

## Compliance & Legal Requirements

### Belgium-Specific Requirements

✅ **Mandatory PEPPOL for B2G**: Since January 2020  
✅ **Invoice Archive**: Must retain for 7 years  
✅ **VAT Compliance**: Follow Belgian VAT rules  
✅ **E-signature**: Not required for PEPPOL invoices  

### EU Requirements

- EN 16931 standard compliance (UBL 2.1 or CII)
- PEPPOL BIS Billing 3.0 specification
- GDPR compliance for customer data

---

## Troubleshooting

### Common Issues

#### 1. PEPPOL ID Not Found

**Error**: Recipient PEPPOL ID not registered  
**Solution**: 
- Verify PEPPOL ID format with recipient
- Use PEPPOL directory lookup
- Fallback to PDF email if recipient not on PEPPOL

#### 2. UBL Validation Errors

**Error**: Invoice doesn't meet PEPPOL BIS 3.0 spec  
**Solution**:
- Use validator: https://test-notier.eu
- Check all mandatory fields present
- Verify VAT rates and calculations

#### 3. Delivery Failures

**Error**: Invoice rejected by recipient system  
**Solution**:
- Check recipient's technical specifications
- Verify endpoint is active
- Contact PEPPOL Access Point support

---

## Resources

### Official Documentation

- **PEPPOL BIS Billing 3.0**: https://docs.peppol.eu/poacc/billing/3.0/
- **UBL 2.1 Specification**: https://docs.oasis-open.org/ubl/UBL-2.1.html
- **Storecove API Docs**: https://www.storecove.com/docs/
- **Belgian PEPPOL Authority**: https://economie.fgov.be/en/themes/online/electronic-invoicing

### Testing Tools

- **PEPPOL Validator**: https://test-notier.eu/peppol-bis-billing-3-0-validator/
- **UBL Validator**: https://suite.ecosio.com/validator
- **PEPPOL Directory**: https://directory.peppol.eu/

### Support Communities

- **PEPPOL User Forum**: https://groups.google.com/g/peppol-user-forum
- **InvoiceNinja Forum**: https://forum.invoiceninja.com/
- **Belgian E-Invoicing**: https://www.unizo.be (for Belgian SMEs)

---

## Next Steps

1. ✅ Choose PEPPOL Access Point Provider (recommend: Storecove for API, Unimaze for manual)
2. ✅ Register your company and obtain PEPPOL ID
3. ✅ Configure InvoiceNinja with custom fields
4. ✅ Build middleware OR use manual portal
5. ✅ Test with sample invoices
6. ✅ Go live with real customers

**Questions?** Contact your PEPPOL provider's support team for assistance!
