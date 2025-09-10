# Azure API for FHIR Configuration

**⚠️ SIMULATION ONLY - NOT FOR CLINICAL USE ⚠️**

*Configuration scripts and setup for Azure API for FHIR with dummy data for My BP demonstration.*

## FHIR Service Configuration Script

```bash
#!/bin/bash
# setup-fhir-service.sh

set -e

# Configuration variables
RESOURCE_GROUP="${1:-rg-mybp-demo-uksouth}"
FHIR_SERVICE_NAME="${2:-fhir-mybp-demo}"
SUBSCRIPTION_ID="${3:-$(az account show --query id -o tsv)}"
LOCATION="${4:-uksouth}"

echo "🏥 Setting up Azure API for FHIR service..."
echo "Resource Group: $RESOURCE_GROUP"
echo "FHIR Service: $FHIR_SERVICE_NAME"
echo "Location: $LOCATION"

# Create FHIR service if it doesn't exist
if ! az healthcareapis service show --name "$FHIR_SERVICE_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
    echo "Creating FHIR service..."
    az healthcareapis service create \
        --name "$FHIR_SERVICE_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --kind "fhir-R4" \
        --tags Environment=demo DataType=dummy Purpose="Healthcare AI Demo"
else
    echo "FHIR service already exists"
fi

# Get FHIR service details
FHIR_ENDPOINT=$(az healthcareapis service show \
    --name "$FHIR_SERVICE_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query "properties.authenticationConfiguration.audience" -o tsv)

echo "FHIR Endpoint: $FHIR_ENDPOINT"

# Configure CORS for demo environment
echo "Configuring CORS settings..."
az healthcareapis service update \
    --name "$FHIR_SERVICE_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --cors-origins "*" \
    --cors-headers "*" \
    --cors-methods "GET,POST,PUT,DELETE,OPTIONS" \
    --cors-max-age 86400 \
    --cors-allow-credentials false

# Create service principal for agent access
echo "Creating service principal for agents..."
AGENT_SP_NAME="sp-mybp-agents-demo"
AGENT_SP_JSON=$(az ad sp create-for-rbac \
    --name "$AGENT_SP_NAME" \
    --role "FHIR Data Contributor" \
    --scopes "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.HealthcareApis/services/$FHIR_SERVICE_NAME" \
    --output json)

AGENT_CLIENT_ID=$(echo "$AGENT_SP_JSON" | jq -r '.appId')
AGENT_CLIENT_SECRET=$(echo "$AGENT_SP_JSON" | jq -r '.password')
TENANT_ID=$(echo "$AGENT_SP_JSON" | jq -r '.tenant')

echo "Agent Service Principal Created:"
echo "  Client ID: $AGENT_CLIENT_ID"
echo "  Tenant ID: $TENANT_ID"

# Store credentials in Key Vault
KV_NAME="kv-mybp-demo"
echo "Storing credentials in Key Vault: $KV_NAME"

az keyvault secret set --vault-name "$KV_NAME" --name "fhir-endpoint" --value "$FHIR_ENDPOINT"
az keyvault secret set --vault-name "$KV_NAME" --name "fhir-client-id" --value "$AGENT_CLIENT_ID"
az keyvault secret set --vault-name "$KV_NAME" --name "fhir-client-secret" --value "$AGENT_CLIENT_SECRET"
az keyvault secret set --vault-name "$KV_NAME" --name "fhir-tenant-id" --value "$TENANT_ID"

# Test FHIR service connectivity
echo "Testing FHIR service connectivity..."
ACCESS_TOKEN=$(az account get-access-token --resource="$FHIR_ENDPOINT" --query accessToken -o tsv)

METADATA_RESPONSE=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" "$FHIR_ENDPOINT/metadata")
FHIR_VERSION=$(echo "$METADATA_RESPONSE" | jq -r '.fhirVersion // "Unknown"')

echo "✅ FHIR Service Setup Complete!"
echo "FHIR Version: $FHIR_VERSION"
echo "Service Endpoint: $FHIR_ENDPOINT"
echo ""
echo "Next steps:"
echo "1. Run the dummy data loading script: python load_dummy_data.py"
echo "2. Deploy agents with FHIR credentials from Key Vault"
```

## FHIR Resource Validation Schema

```python
# fhir_validator.py
from typing import Dict, Any, List, Optional
import re
from datetime import datetime
import json

class FHIRValidator:
    """Validator for FHIR R4 resources with dummy data requirements"""
    
    def __init__(self):
        self.dummy_data_extension_url = "http://mybp.nhs.uk/fhir/extension/dummy-data-marker"
        self.required_extensions = [
            "http://mybp.nhs.uk/fhir/extension/dummy-data-marker",
            "http://mybp.nhs.uk/fhir/extension/patient-category"
        ]
    
    def validate_patient(self, patient: Dict[str, Any]) -> List[str]:
        """Validate Patient resource for My BP demo requirements"""
        errors = []
        
        # Check resource type
        if patient.get('resourceType') != 'Patient':
            errors.append("Resource type must be 'Patient'")
            return errors
        
        # Validate dummy data marker
        if not self._has_dummy_data_marker(patient):
            errors.append("Patient must have dummy data marker extension")
        
        # Validate NHS number format for dummy data
        identifiers = patient.get('identifier', [])
        nhs_identifier = None
        for identifier in identifiers:
            if identifier.get('type', {}).get('coding', [{}])[0].get('code') == 'NH':
                nhs_identifier = identifier
                break
        
        if nhs_identifier:
            nhs_number = nhs_identifier.get('value', '')
            if not nhs_number.startswith('DEMO'):
                errors.append("NHS number must start with 'DEMO' for dummy data")
            if not re.match(r'^DEMO\d{9}$', nhs_number):
                errors.append("NHS number format invalid for dummy data (should be DEMO followed by 9 digits)")
        else:
            errors.append("Patient must have NHS number identifier")
        
        # Validate patient category extension
        if not self._has_patient_category_extension(patient):
            errors.append("Patient must have patient category extension (A, B, or C)")
        
        # Validate required fields
        if not patient.get('name'):
            errors.append("Patient must have name")
        
        if not patient.get('birthDate'):
            errors.append("Patient must have birth date")
        
        if not patient.get('gender'):
            errors.append("Patient must have gender")
        
        # Validate demo tags
        if not self._has_demo_tag(patient):
            errors.append("Patient must have 'demo-data' tag in meta.tag")
        
        return errors
    
    def validate_observation(self, observation: Dict[str, Any]) -> List[str]:
        """Validate Observation resource for BP measurements"""
        errors = []
        
        if observation.get('resourceType') != 'Observation':
            errors.append("Resource type must be 'Observation'")
            return errors
        
        # Check dummy data marker
        if not self._has_dummy_data_marker(observation):
            errors.append("Observation must have dummy data marker extension")
        
        # Validate BP observation specifics
        code = observation.get('code', {})
        if not self._is_bp_observation(code):
            errors.append("Observation must be a blood pressure measurement")
        
        # Validate components for BP
        components = observation.get('component', [])
        systolic_found = False
        diastolic_found = False
        
        for component in components:
            comp_code = component.get('code', {}).get('coding', [{}])[0].get('code')
            if comp_code == '8480-6':  # Systolic BP
                systolic_found = True
                if not self._validate_bp_value(component.get('valueQuantity')):
                    errors.append("Invalid systolic BP value")
            elif comp_code == '8462-4':  # Diastolic BP
                diastolic_found = True
                if not self._validate_bp_value(component.get('valueQuantity')):
                    errors.append("Invalid diastolic BP value")
        
        if not systolic_found:
            errors.append("BP observation must have systolic component")
        if not diastolic_found:
            errors.append("BP observation must have diastolic component")
        
        # Validate subject reference
        subject = observation.get('subject', {}).get('reference', '')
        if not subject.startswith('Patient/dummy-patient-'):
            errors.append("Observation subject must reference a dummy patient")
        
        # Validate status
        if observation.get('status') not in ['final', 'preliminary', 'registered']:
            errors.append("Observation status must be valid FHIR status")
        
        return errors
    
    def validate_care_plan(self, care_plan: Dict[str, Any]) -> List[str]:
        """Validate CarePlan resource for hypertension management"""
        errors = []
        
        if care_plan.get('resourceType') != 'CarePlan':
            errors.append("Resource type must be 'CarePlan'")
            return errors
        
        # Check dummy data marker
        if not self._has_dummy_data_marker(care_plan):
            errors.append("CarePlan must have dummy data marker extension")
        
        # Validate required fields
        if not care_plan.get('status'):
            errors.append("CarePlan must have status")
        
        if care_plan.get('status') not in ['draft', 'active', 'on-hold', 'revoked', 'completed']:
            errors.append("CarePlan status must be valid")
        
        if not care_plan.get('intent'):
            errors.append("CarePlan must have intent")
        
        # Validate subject
        subject = care_plan.get('subject', {}).get('reference', '')
        if not subject.startswith('Patient/dummy-patient-'):
            errors.append("CarePlan subject must reference a dummy patient")
        
        # Validate category for hypertension
        categories = care_plan.get('category', [])
        hypertension_category_found = False
        for category in categories:
            for coding in category.get('coding', []):
                if coding.get('code') == '736353002':  # Hypertension care plan
                    hypertension_category_found = True
                    break
        
        if not hypertension_category_found:
            errors.append("CarePlan must have hypertension category")
        
        return errors
    
    def validate_flag(self, flag: Dict[str, Any]) -> List[str]:
        """Validate Flag resource for clinical alerts"""
        errors = []
        
        if flag.get('resourceType') != 'Flag':
            errors.append("Resource type must be 'Flag'")
            return errors
        
        # Check dummy data marker
        if not self._has_dummy_data_marker(flag):
            errors.append("Flag must have dummy data marker extension")
        
        # Validate required fields
        if not flag.get('status'):
            errors.append("Flag must have status")
        
        if flag.get('status') not in ['active', 'inactive', 'entered-in-error']:
            errors.append("Flag status must be valid")
        
        # Validate subject
        subject = flag.get('subject', {}).get('reference', '')
        if not subject.startswith('Patient/dummy-patient-'):
            errors.append("Flag subject must reference a dummy patient")
        
        # Validate category
        categories = flag.get('category', [])
        if not categories:
            errors.append("Flag must have category")
        
        return errors
    
    def _has_dummy_data_marker(self, resource: Dict[str, Any]) -> bool:
        """Check if resource has dummy data marker extension"""
        extensions = resource.get('extension', [])
        for ext in extensions:
            if ext.get('url') == self.dummy_data_extension_url and ext.get('valueBoolean') is True:
                return True
        return False
    
    def _has_patient_category_extension(self, patient: Dict[str, Any]) -> bool:
        """Check if patient has category extension"""
        extensions = patient.get('extension', [])
        for ext in extensions:
            if ext.get('url') == "http://mybp.nhs.uk/fhir/extension/patient-category":
                category = ext.get('valueString')
                return category in ['A', 'B', 'C']
        return False
    
    def _has_demo_tag(self, resource: Dict[str, Any]) -> bool:
        """Check if resource has demo data tag"""
        tags = resource.get('meta', {}).get('tag', [])
        for tag in tags:
            if tag.get('code') == 'demo-data':
                return True
        return False
    
    def _is_bp_observation(self, code: Dict[str, Any]) -> bool:
        """Check if observation is a blood pressure measurement"""
        codings = code.get('coding', [])
        for coding in codings:
            if coding.get('code') in ['85354-9', '75367002']:  # LOINC or SNOMED BP codes
                return True
        return False
    
    def _validate_bp_value(self, quantity: Optional[Dict[str, Any]]) -> bool:
        """Validate blood pressure value"""
        if not quantity:
            return False
        
        value = quantity.get('value')
        unit = quantity.get('unit')
        
        if not isinstance(value, (int, float)):
            return False
        
        if unit != 'mmHg':
            return False
        
        # Validate reasonable BP range for demo data
        if value < 50 or value > 250:
            return False
        
        return True

# Example usage
def validate_fhir_resource(resource: Dict[str, Any]) -> Dict[str, Any]:
    """Validate a FHIR resource and return validation results"""
    validator = FHIRValidator()
    resource_type = resource.get('resourceType')
    
    if resource_type == 'Patient':
        errors = validator.validate_patient(resource)
    elif resource_type == 'Observation':
        errors = validator.validate_observation(resource)
    elif resource_type == 'CarePlan':
        errors = validator.validate_care_plan(resource)
    elif resource_type == 'Flag':
        errors = validator.validate_flag(resource)
    else:
        errors = [f"Unsupported resource type: {resource_type}"]
    
    return {
        'resource_id': resource.get('id', 'unknown'),
        'resource_type': resource_type,
        'valid': len(errors) == 0,
        'errors': errors,
        'warnings': [],
        'validation_timestamp': datetime.utcnow().isoformat()
    }

if __name__ == "__main__":
    # Example validation
    sample_patient = {
        "resourceType": "Patient",
        "id": "dummy-patient-001",
        "identifier": [{
            "use": "usual",
            "type": {"coding": [{"code": "NH"}]},
            "value": "DEMO123456789"
        }],
        "name": [{"family": "TestPatient", "given": ["Demo"]}],
        "gender": "male",
        "birthDate": "1975-01-01",
        "extension": [
            {
                "url": "http://mybp.nhs.uk/fhir/extension/dummy-data-marker",
                "valueBoolean": True
            },
            {
                "url": "http://mybp.nhs.uk/fhir/extension/patient-category",
                "valueString": "A"
            }
        ],
        "meta": {
            "tag": [{"code": "demo-data"}]
        }
    }
    
    result = validate_fhir_resource(sample_patient)
    print(json.dumps(result, indent=2))
```

## Dummy Data Loading Script

```python
# load_dummy_data.py
import asyncio
import json
import uuid
from datetime import datetime, timedelta
from typing import List, Dict, Any
import aiohttp
from azure.identity import DefaultAzureCredential
import random

class DummyFHIRDataLoader:
    """Load dummy FHIR data for My BP demonstration"""
    
    def __init__(self, fhir_endpoint: str, tenant_id: str, client_id: str, client_secret: str):
        self.fhir_endpoint = fhir_endpoint.rstrip('/')
        self.tenant_id = tenant_id
        self.client_id = client_id
        self.client_secret = client_secret
        self.access_token = None
        
        # Dummy data configurations
        self.patient_scenarios = [
            'newly-diagnosed',
            'treatment-resistant',
            'medication-adherence-issues', 
            'red-flag-scenario',
            'stable-management',
            'lifestyle-intervention',
            'surveillance-routine',
            'surveillance-family-history',
            'newly-detected-pharmacy',
            'newly-detected-health-check'
        ]
    
    async def load_all_dummy_data(self):
        """Load complete set of dummy data for demonstration"""
        print("🏥 Loading dummy FHIR data for My BP demonstration...")
        
        # Get access token
        await self._get_access_token()
        
        # Generate and load patients by category
        category_a_patients = await self._generate_category_a_patients(25)
        category_b_patients = await self._generate_category_b_patients(15)  
        category_c_patients = await self._generate_category_c_patients(10)
        
        all_patients = category_a_patients + category_b_patients + category_c_patients
        
        # Load patients
        print(f"Loading {len(all_patients)} dummy patients...")
        for patient in all_patients:
            await self._create_resource(patient)
            print(f"✅ Created patient: {patient['id']}")
        
        # Generate and load related resources for each patient
        for patient in all_patients:
            patient_id = patient['id']
            scenario = patient['extension'][2]['valueString']  # simulation scenario
            
            # Generate BP readings
            bp_readings = self._generate_bp_readings(patient_id, scenario, days=90)
            for reading in bp_readings:
                await self._create_resource(reading)
            
            # Generate care plan
            care_plan = self._generate_care_plan(patient_id, scenario)
            await self._create_resource(care_plan)
            
            # Generate medications (for Category A)
            if patient['extension'][1]['valueString'] == 'A':
                medications = self._generate_medications(patient_id, scenario)
                for medication in medications:
                    await self._create_resource(medication)
            
            # Generate clinical alerts (for some scenarios)
            if scenario in ['red-flag-scenario', 'treatment-resistant']:
                alerts = self._generate_clinical_alerts(patient_id, scenario)
                for alert in alerts:
                    await self._create_resource(alert)
            
            print(f"✅ Generated data for patient {patient_id} ({scenario})")
        
        print("🎉 Dummy data loading complete!")
        print(f"Total patients loaded: {len(all_patients)}")
        print("Data includes: BP readings, care plans, medications, and clinical alerts")
        print("⚠️  All data is marked as dummy/simulation data only")
    
    async def _get_access_token(self):
        """Get Azure AD access token for FHIR service"""
        token_url = f"https://login.microsoftonline.com/{self.tenant_id}/oauth2/v2.0/token"
        
        data = {
            'grant_type': 'client_credentials',
            'client_id': self.client_id,
            'client_secret': self.client_secret,
            'scope': f'{self.fhir_endpoint}/.default'
        }
        
        async with aiohttp.ClientSession() as session:
            async with session.post(token_url, data=data) as response:
                if response.status == 200:
                    token_data = await response.json()
                    self.access_token = token_data['access_token']
                    print("✅ Obtained FHIR access token")
                else:
                    raise Exception(f"Failed to get access token: {response.status}")
    
    async def _create_resource(self, resource: Dict[str, Any]):
        """Create a FHIR resource"""
        resource_type = resource['resourceType']
        url = f"{self.fhir_endpoint}/{resource_type}"
        
        headers = {
            'Authorization': f'Bearer {self.access_token}',
            'Content-Type': 'application/fhir+json',
            'Accept': 'application/fhir+json'
        }
        
        async with aiohttp.ClientSession() as session:
            async with session.post(url, json=resource, headers=headers) as response:
                if response.status in [200, 201]:
                    return await response.json()
                else:
                    error_text = await response.text()
                    raise Exception(f"Failed to create {resource_type}: {response.status} - {error_text}")
    
    async def _generate_category_a_patients(self, count: int) -> List[Dict[str, Any]]:
        """Generate Category A patients (known hypertension)"""
        patients = []
        scenarios = ['stable-management', 'treatment-resistant', 'medication-adherence-issues', 'red-flag-scenario']
        
        for i in range(count):
            scenario = scenarios[i % len(scenarios)]
            patient = self._create_patient_base(f"dummy-patient-a{i:03d}", scenario, 'A')
            patients.append(patient)
        
        return patients
    
    async def _generate_category_b_patients(self, count: int) -> List[Dict[str, Any]]:
        """Generate Category B patients (surveillance)"""
        patients = []
        scenarios = ['surveillance-routine', 'surveillance-family-history']
        
        for i in range(count):
            scenario = scenarios[i % len(scenarios)]
            patient = self._create_patient_base(f"dummy-patient-b{i:03d}", scenario, 'B')
            patients.append(patient)
        
        return patients
    
    async def _generate_category_c_patients(self, count: int) -> List[Dict[str, Any]]:
        """Generate Category C patients (newly detected)"""
        patients = []
        scenarios = ['newly-detected-pharmacy', 'newly-detected-health-check', 'newly-diagnosed']
        
        for i in range(count):
            scenario = scenarios[i % len(scenarios)]
            patient = self._create_patient_base(f"dummy-patient-c{i:03d}", scenario, 'C')
            patients.append(patient)
        
        return patients
    
    def _create_patient_base(self, patient_id: str, scenario: str, category: str) -> Dict[str, Any]:
        """Create base patient resource"""
        # Generate demographic data
        first_names = ['James', 'Mary', 'John', 'Patricia', 'Robert', 'Jennifer', 'Michael', 'Linda', 'David', 'Elizabeth']
        last_names = ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez']
        
        first_name = random.choice(first_names)
        last_name = random.choice(last_names)
        gender = random.choice(['male', 'female'])
        
        # Generate age based on category
        if category == 'A':
            age = random.randint(45, 75)  # Known hypertension typically older
        elif category == 'B':
            age = random.randint(35, 65)  # Surveillance patients
        else:
            age = random.randint(40, 70)  # Newly detected
        
        birth_date = (datetime.now() - timedelta(days=age*365)).strftime('%Y-%m-%d')
        
        return {
            "resourceType": "Patient",
            "id": patient_id,
            "identifier": [{
                "use": "usual",
                "type": {
                    "coding": [{
                        "system": "https://fhir.nhs.uk/Id/nhs-number",
                        "code": "NH"
                    }]
                },
                "value": f"DEMO{random.randint(100000000, 999999999)}"
            }],
            "active": True,
            "name": [{
                "use": "official",
                "family": last_name,
                "given": [first_name, "Demo"],
                "prefix": ["Mr" if gender == "male" else "Ms"]
            }],
            "telecom": [
                {
                    "system": "phone",
                    "value": f"DEMO-{random.randint(1000000000, 9999999999)}",
                    "use": "mobile"
                },
                {
                    "system": "email",
                    "value": f"demo.{first_name.lower()}.{last_name.lower()}@simulation.nhs.uk",
                    "use": "home"
                }
            ],
            "gender": gender,
            "birthDate": birth_date,
            "address": [{
                "use": "home",
                "line": [f"{random.randint(1, 999)} Demo Street"],
                "city": "Cambridge",
                "postalCode": f"CB{random.randint(1, 9)} {random.randint(1, 9)}AB",
                "country": "GB"
            }],
            "extension": [
                {
                    "url": "http://mybp.nhs.uk/fhir/extension/dummy-data-marker",
                    "valueBoolean": True
                },
                {
                    "url": "http://mybp.nhs.uk/fhir/extension/patient-category",
                    "valueString": category
                },
                {
                    "url": "http://mybp.nhs.uk/fhir/extension/simulation-scenario",
                    "valueString": scenario
                }
            ],
            "meta": {
                "profile": ["https://fhir.nhs.uk/STU3/StructureDefinition/CareConnect-Patient-1"],
                "tag": [{
                    "system": "http://mybp.nhs.uk/fhir/tags",
                    "code": "demo-data",
                    "display": "Demonstration Data Only"
                }]
            }
        }
    
    def _generate_bp_readings(self, patient_id: str, scenario: str, days: int = 90) -> List[Dict[str, Any]]:
        """Generate BP readings based on scenario"""
        readings = []
        
        # Base readings per scenario
        base_readings = {
            'newly-diagnosed': (155, 95),
            'treatment-resistant': (165, 100),
            'medication-adherence-issues': (150, 92),
            'red-flag-scenario': (185, 110),
            'stable-management': (130, 80),
            'lifestyle-intervention': (140, 88),
            'surveillance-routine': (125, 78),
            'surveillance-family-history': (135, 82),
            'newly-detected-pharmacy': (148, 90),
            'newly-detected-health-check': (152, 88)
        }
        
        base_systolic, base_diastolic = base_readings.get(scenario, (140, 90))
        
        # Generate readings over time
        for week in range(0, days // 7):
            date = datetime.now() - timedelta(days=days - (week * 7))
            
            # Add some variation and trend
            systolic_variation = random.randint(-10, 10)
            diastolic_variation = random.randint(-5, 5)
            
            # Simulate treatment response for some scenarios
            if scenario in ['stable-management', 'lifestyle-intervention'] and week > 4:
                systolic_variation -= 5  # Improvement over time
                diastolic_variation -= 3
            
            systolic = max(90, min(220, base_systolic + systolic_variation))
            diastolic = max(60, min(120, base_diastolic + diastolic_variation))
            
            reading = {
                "resourceType": "Observation",
                "id": f"dummy-bp-{patient_id}-{week:03d}",
                "status": "final",
                "category": [{
                    "coding": [{
                        "system": "http://terminology.hl7.org/CodeSystem/observation-category",
                        "code": "vital-signs",
                        "display": "Vital Signs"
                    }]
                }],
                "code": {
                    "coding": [
                        {
                            "system": "http://loinc.org",
                            "code": "85354-9",
                            "display": "Blood pressure panel with all children optional"
                        },
                        {
                            "system": "http://snomed.info/sct",
                            "code": "75367002",
                            "display": "Blood pressure"
                        }
                    ]
                },
                "subject": {"reference": f"Patient/{patient_id}"},
                "effectiveDateTime": date.isoformat() + "Z",
                "component": [
                    {
                        "code": {"coding": [{"system": "http://loinc.org", "code": "8480-6", "display": "Systolic blood pressure"}]},
                        "valueQuantity": {"value": systolic, "unit": "mmHg", "system": "http://unitsofmeasure.org", "code": "mm[Hg]"}
                    },
                    {
                        "code": {"coding": [{"system": "http://loinc.org", "code": "8462-4", "display": "Diastolic blood pressure"}]},
                        "valueQuantity": {"value": diastolic, "unit": "mmHg", "system": "http://unitsofmeasure.org", "code": "mm[Hg]"}
                    }
                ],
                "extension": [{
                    "url": "http://mybp.nhs.uk/fhir/extension/dummy-data-marker",
                    "valueBoolean": True
                }],
                "meta": {
                    "tag": [{"system": "http://mybp.nhs.uk/fhir/tags", "code": "demo-data", "display": "Demonstration Data Only"}]
                }
            }
            
            readings.append(reading)
        
        return readings
    
    def _generate_care_plan(self, patient_id: str, scenario: str) -> Dict[str, Any]:
        """Generate care plan for patient"""
        return {
            "resourceType": "CarePlan",
            "id": f"dummy-careplan-{patient_id}",
            "status": "active",
            "intent": "plan",
            "category": [{
                "coding": [{
                    "system": "http://snomed.info/sct",
                    "code": "736353002",
                    "display": "Hypertension care plan"
                }]
            }],
            "title": "My BP Hypertension Management Care Plan",
            "description": f"AI-driven care plan for hypertension management - {scenario} scenario",
            "subject": {"reference": f"Patient/{patient_id}"},
            "period": {
                "start": datetime.now().strftime('%Y-%m-%d'),
                "end": (datetime.now() + timedelta(days=365)).strftime('%Y-%m-%d')
            },
            "created": datetime.now().isoformat() + "Z",
            "extension": [
                {
                    "url": "http://mybp.nhs.uk/fhir/extension/dummy-data-marker",
                    "valueBoolean": True
                },
                {
                    "url": "http://mybp.nhs.uk/fhir/extension/agent-managed",
                    "valueBoolean": True
                },
                {
                    "url": "http://mybp.nhs.uk/fhir/extension/care-pathway-stage",
                    "valueString": "active-management"
                }
            ],
            "meta": {
                "tag": [{"system": "http://mybp.nhs.uk/fhir/tags", "code": "demo-data", "display": "Demonstration Data Only"}]
            }
        }
    
    def _generate_medications(self, patient_id: str, scenario: str) -> List[Dict[str, Any]]:
        """Generate medication statements for Category A patients"""
        medications = []
        
        # Common BP medications for demo
        bp_medications = [
            {"name": "Amlodipine", "dose": "5mg", "code": "108537001"},
            {"name": "Ramipril", "dose": "2.5mg", "code": "386872004"},
            {"name": "Indapamide", "dose": "2.5mg", "code": "387467008"}
        ]
        
        # Assign medications based on scenario
        if scenario in ['stable-management', 'newly-diagnosed']:
            selected_meds = bp_medications[:1]  # Single therapy
        elif scenario in ['treatment-resistant']:
            selected_meds = bp_medications  # Triple therapy
        else:
            selected_meds = bp_medications[:2]  # Dual therapy
        
        for i, med in enumerate(selected_meds):
            medication = {
                "resourceType": "MedicationStatement",
                "id": f"dummy-med-{patient_id}-{i:03d}",
                "status": "active",
                "medicationCodeableConcept": {
                    "coding": [{
                        "system": "http://snomed.info/sct",
                        "code": med["code"],
                        "display": med["name"]
                    }]
                },
                "subject": {"reference": f"Patient/{patient_id}"},
                "effectiveDateTime": datetime.now().isoformat() + "Z",
                "dosage": [{
                    "text": f"{med['dose']} once daily",
                    "timing": {"repeat": {"frequency": 1, "period": 1, "periodUnit": "d"}},
                    "doseAndRate": [{
                        "doseQuantity": {"value": float(med["dose"].replace("mg", "")), "unit": "mg"}
                    }]
                }],
                "extension": [{
                    "url": "http://mybp.nhs.uk/fhir/extension/dummy-data-marker",
                    "valueBoolean": True
                }],
                "meta": {
                    "tag": [{"system": "http://mybp.nhs.uk/fhir/tags", "code": "demo-data", "display": "Demonstration Data Only"}]
                }
            }
            medications.append(medication)
        
        return medications
    
    def _generate_clinical_alerts(self, patient_id: str, scenario: str) -> List[Dict[str, Any]]:
        """Generate clinical alerts for certain scenarios"""
        alerts = []
        
        if scenario == 'red-flag-scenario':
            alert = {
                "resourceType": "Flag",
                "id": f"dummy-alert-{patient_id}-critical",
                "status": "active",
                "category": [{
                    "coding": [{
                        "system": "http://terminology.hl7.org/CodeSystem/flag-category",
                        "code": "clinical",
                        "display": "Clinical"
                    }]
                }],
                "code": {
                    "coding": [{
                        "system": "http://mybp.nhs.uk/fhir/alert-codes",
                        "code": "critical-bp",
                        "display": "Critical blood pressure reading"
                    }]
                },
                "subject": {"reference": f"Patient/{patient_id}"},
                "period": {"start": datetime.now().isoformat() + "Z"},
                "extension": [
                    {
                        "url": "http://mybp.nhs.uk/fhir/extension/dummy-data-marker",
                        "valueBoolean": True
                    },
                    {
                        "url": "http://mybp.nhs.uk/fhir/extension/alert-severity",
                        "valueString": "critical"
                    }
                ],
                "meta": {
                    "tag": [{"system": "http://mybp.nhs.uk/fhir/tags", "code": "demo-data", "display": "Demonstration Data Only"}]
                }
            }
            alerts.append(alert)
        
        return alerts

# CLI interface
if __name__ == "__main__":
    import sys
    import os
    
    # Get configuration from environment or command line
    fhir_endpoint = os.getenv('FHIR_ENDPOINT') or sys.argv[1] if len(sys.argv) > 1 else None
    tenant_id = os.getenv('AZURE_TENANT_ID') or sys.argv[2] if len(sys.argv) > 2 else None
    client_id = os.getenv('AZURE_CLIENT_ID') or sys.argv[3] if len(sys.argv) > 3 else None
    client_secret = os.getenv('AZURE_CLIENT_SECRET') or sys.argv[4] if len(sys.argv) > 4 else None
    
    if not all([fhir_endpoint, tenant_id, client_id, client_secret]):
        print("Usage: python load_dummy_data.py <fhir_endpoint> <tenant_id> <client_id> <client_secret>")
        print("Or set environment variables: FHIR_ENDPOINT, AZURE_TENANT_ID, AZURE_CLIENT_ID, AZURE_CLIENT_SECRET")
        sys.exit(1)
    
    loader = DummyFHIRDataLoader(fhir_endpoint, tenant_id, client_id, client_secret)
    asyncio.run(loader.load_all_dummy_data())
```

---

**These FHIR configuration files provide comprehensive setup for Azure API for FHIR with proper validation and dummy data loading for the My BP demonstration system.**