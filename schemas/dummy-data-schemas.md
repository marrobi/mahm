# My BP Dummy Data Schemas

**⚠️ SIMULATION ONLY - NOT FOR CLINICAL USE ⚠️**

*FHIR-compliant dummy data schemas and sample data for the My BP multi-agentic AI demonstration system.*

## Core Data Types

### Patient Schema (FHIR Patient Resource)

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "My BP Dummy Patient Schema",
  "type": "object",
  "required": ["resourceType", "id", "identifier", "name", "gender", "birthDate", "extension", "meta"],
  "properties": {
    "resourceType": {
      "type": "string",
      "const": "Patient"
    },
    "id": {
      "type": "string",
      "pattern": "^dummy-patient-[a-z]\\d{3}$",
      "description": "Must start with 'dummy-patient-' followed by category letter and 3 digits"
    },
    "identifier": {
      "type": "array",
      "minItems": 1,
      "items": {
        "type": "object",
        "required": ["use", "type", "value"],
        "properties": {
          "use": {"type": "string", "enum": ["usual"]},
          "type": {
            "type": "object",
            "properties": {
              "coding": {
                "type": "array",
                "items": {
                  "type": "object",
                  "properties": {
                    "system": {"const": "https://fhir.nhs.uk/Id/nhs-number"},
                    "code": {"const": "NH"}
                  }
                }
              }
            }
          },
          "value": {
            "type": "string",
            "pattern": "^DEMO\\d{9}$",
            "description": "Must start with 'DEMO' followed by 9 digits"
          }
        }
      }
    },
    "name": {
      "type": "array",
      "minItems": 1,
      "items": {
        "type": "object",
        "required": ["use", "family", "given"],
        "properties": {
          "use": {"type": "string", "enum": ["official"]},
          "family": {"type": "string"},
          "given": {
            "type": "array",
            "items": {"type": "string"}
          },
          "prefix": {
            "type": "array",
            "items": {"type": "string", "enum": ["Mr", "Ms", "Mrs", "Dr"]}
          }
        }
      }
    },
    "gender": {
      "type": "string",
      "enum": ["male", "female", "other", "unknown"]
    },
    "birthDate": {
      "type": "string",
      "format": "date",
      "description": "Birth date in YYYY-MM-DD format"
    },
    "extension": {
      "type": "array",
      "minItems": 2,
      "items": {
        "oneOf": [
          {
            "type": "object",
            "required": ["url", "valueBoolean"],
            "properties": {
              "url": {"const": "http://mybp.nhs.uk/fhir/extension/dummy-data-marker"},
              "valueBoolean": {"const": true}
            }
          },
          {
            "type": "object",
            "required": ["url", "valueString"],
            "properties": {
              "url": {"const": "http://mybp.nhs.uk/fhir/extension/patient-category"},
              "valueString": {"enum": ["A", "B", "C"]}
            }
          },
          {
            "type": "object",
            "required": ["url", "valueString"],
            "properties": {
              "url": {"const": "http://mybp.nhs.uk/fhir/extension/simulation-scenario"},
              "valueString": {
                "enum": [
                  "newly-diagnosed",
                  "treatment-resistant",
                  "medication-adherence-issues",
                  "red-flag-scenario",
                  "stable-management",
                  "lifestyle-intervention",
                  "surveillance-routine",
                  "surveillance-family-history",
                  "newly-detected-pharmacy",
                  "newly-detected-health-check"
                ]
              }
            }
          }
        ]
      }
    },
    "meta": {
      "type": "object",
      "required": ["tag"],
      "properties": {
        "tag": {
          "type": "array",
          "minItems": 1,
          "items": {
            "type": "object",
            "required": ["system", "code", "display"],
            "properties": {
              "system": {"const": "http://mybp.nhs.uk/fhir/tags"},
              "code": {"const": "demo-data"},
              "display": {"const": "Demonstration Data Only"}
            }
          }
        }
      }
    }
  }
}
```

### Blood Pressure Observation Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "My BP Blood Pressure Observation Schema",
  "type": "object",
  "required": ["resourceType", "id", "status", "category", "code", "subject", "effectiveDateTime", "component", "extension", "meta"],
  "properties": {
    "resourceType": {
      "type": "string",
      "const": "Observation"
    },
    "id": {
      "type": "string",
      "pattern": "^dummy-bp-dummy-patient-[a-z]\\d{3}-\\d{3}$"
    },
    "status": {
      "type": "string",
      "enum": ["final", "preliminary", "registered"]
    },
    "category": {
      "type": "array",
      "minItems": 1,
      "items": {
        "type": "object",
        "required": ["coding"],
        "properties": {
          "coding": {
            "type": "array",
            "items": {
              "type": "object",
              "required": ["system", "code", "display"],
              "properties": {
                "system": {"const": "http://terminology.hl7.org/CodeSystem/observation-category"},
                "code": {"const": "vital-signs"},
                "display": {"const": "Vital Signs"}
              }
            }
          }
        }
      }
    },
    "code": {
      "type": "object",
      "required": ["coding"],
      "properties": {
        "coding": {
          "type": "array",
          "minItems": 1,
          "items": {
            "type": "object",
            "required": ["system", "code", "display"],
            "properties": {
              "system": {
                "enum": ["http://loinc.org", "http://snomed.info/sct"]
              },
              "code": {
                "enum": ["85354-9", "75367002"]
              },
              "display": {"type": "string"}
            }
          }
        }
      }
    },
    "subject": {
      "type": "object",
      "required": ["reference"],
      "properties": {
        "reference": {
          "type": "string",
          "pattern": "^Patient/dummy-patient-[a-z]\\d{3}$"
        }
      }
    },
    "effectiveDateTime": {
      "type": "string",
      "format": "date-time"
    },
    "component": {
      "type": "array",
      "minItems": 2,
      "maxItems": 2,
      "items": {
        "oneOf": [
          {
            "type": "object",
            "required": ["code", "valueQuantity"],
            "properties": {
              "code": {
                "type": "object",
                "properties": {
                  "coding": {
                    "type": "array",
                    "items": {
                      "type": "object",
                      "properties": {
                        "system": {"const": "http://loinc.org"},
                        "code": {"const": "8480-6"},
                        "display": {"const": "Systolic blood pressure"}
                      }
                    }
                  }
                }
              },
              "valueQuantity": {
                "type": "object",
                "required": ["value", "unit", "system"],
                "properties": {
                  "value": {
                    "type": "number",
                    "minimum": 70,
                    "maximum": 250
                  },
                  "unit": {"const": "mmHg"},
                  "system": {"const": "http://unitsofmeasure.org"},
                  "code": {"const": "mm[Hg]"}
                }
              }
            }
          },
          {
            "type": "object",
            "required": ["code", "valueQuantity"],
            "properties": {
              "code": {
                "type": "object",
                "properties": {
                  "coding": {
                    "type": "array",
                    "items": {
                      "type": "object",
                      "properties": {
                        "system": {"const": "http://loinc.org"},
                        "code": {"const": "8462-4"},
                        "display": {"const": "Diastolic blood pressure"}
                      }
                    }
                  }
                }
              },
              "valueQuantity": {
                "type": "object",
                "required": ["value", "unit", "system"],
                "properties": {
                  "value": {
                    "type": "number",
                    "minimum": 40,
                    "maximum": 150
                  },
                  "unit": {"const": "mmHg"},
                  "system": {"const": "http://unitsofmeasure.org"},
                  "code": {"const": "mm[Hg]"}
                }
              }
            }
          }
        ]
      }
    },
    "extension": {
      "type": "array",
      "minItems": 1,
      "items": {
        "type": "object",
        "required": ["url", "valueBoolean"],
        "properties": {
          "url": {"const": "http://mybp.nhs.uk/fhir/extension/dummy-data-marker"},
          "valueBoolean": {"const": true}
        }
      }
    },
    "meta": {
      "type": "object",
      "required": ["tag"],
      "properties": {
        "tag": {
          "type": "array",
          "items": {
            "type": "object",
            "required": ["system", "code", "display"],
            "properties": {
              "system": {"const": "http://mybp.nhs.uk/fhir/tags"},
              "code": {"const": "demo-data"},
              "display": {"const": "Demonstration Data Only"}
            }
          }
        }
      }
    }
  }
}
```

## Sample Data Sets

### Category A Patients (Known Hypertension)

```json
{
  "category_a_samples": [
    {
      "resourceType": "Patient",
      "id": "dummy-patient-a001",
      "identifier": [{
        "use": "usual",
        "type": {
          "coding": [{
            "system": "https://fhir.nhs.uk/Id/nhs-number",
            "code": "NH"
          }]
        },
        "value": "DEMO123456001"
      }],
      "active": true,
      "name": [{
        "use": "official",
        "family": "TestPatient",
        "given": ["John", "Demo"],
        "prefix": ["Mr"]
      }],
      "telecom": [
        {
          "system": "phone",
          "value": "DEMO-07700900001",
          "use": "mobile"
        },
        {
          "system": "email",
          "value": "demo.john.testpatient@simulation.nhs.uk",
          "use": "home"
        }
      ],
      "gender": "male",
      "birthDate": "1965-03-15",
      "address": [{
        "use": "home",
        "line": ["123 Demo Street"],
        "city": "Cambridge",
        "postalCode": "CB1 2AB",
        "country": "GB"
      }],
      "extension": [
        {
          "url": "http://mybp.nhs.uk/fhir/extension/dummy-data-marker",
          "valueBoolean": true
        },
        {
          "url": "http://mybp.nhs.uk/fhir/extension/patient-category",
          "valueString": "A"
        },
        {
          "url": "http://mybp.nhs.uk/fhir/extension/simulation-scenario",
          "valueString": "stable-management"
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
    },
    {
      "resourceType": "Patient",
      "id": "dummy-patient-a002",
      "identifier": [{
        "use": "usual",
        "type": {
          "coding": [{
            "system": "https://fhir.nhs.uk/Id/nhs-number",
            "code": "NH"
          }]
        },
        "value": "DEMO123456002"
      }],
      "active": true,
      "name": [{
        "use": "official",
        "family": "ResistantCase",
        "given": ["Mary", "Demo"],
        "prefix": ["Ms"]
      }],
      "gender": "female",
      "birthDate": "1958-11-22",
      "extension": [
        {
          "url": "http://mybp.nhs.uk/fhir/extension/dummy-data-marker",
          "valueBoolean": true
        },
        {
          "url": "http://mybp.nhs.uk/fhir/extension/patient-category",
          "valueString": "A"
        },
        {
          "url": "http://mybp.nhs.uk/fhir/extension/simulation-scenario",
          "valueString": "treatment-resistant"
        }
      ],
      "meta": {
        "tag": [{
          "system": "http://mybp.nhs.uk/fhir/tags",
          "code": "demo-data",
          "display": "Demonstration Data Only"
        }]
      }
    }
  ]
}
```

### Category B Patients (Surveillance)

```json
{
  "category_b_samples": [
    {
      "resourceType": "Patient",
      "id": "dummy-patient-b001",
      "identifier": [{
        "use": "usual",
        "type": {
          "coding": [{
            "system": "https://fhir.nhs.uk/Id/nhs-number",
            "code": "NH"
          }]
        },
        "value": "DEMO123456101"
      }],
      "active": true,
      "name": [{
        "use": "official",
        "family": "SurveillancePatient",
        "given": ["James", "Demo"],
        "prefix": ["Mr"]
      }],
      "gender": "male",
      "birthDate": "1980-07-10",
      "extension": [
        {
          "url": "http://mybp.nhs.uk/fhir/extension/dummy-data-marker",
          "valueBoolean": true
        },
        {
          "url": "http://mybp.nhs.uk/fhir/extension/patient-category",
          "valueString": "B"
        },
        {
          "url": "http://mybp.nhs.uk/fhir/extension/simulation-scenario",
          "valueString": "surveillance-routine"
        }
      ],
      "meta": {
        "tag": [{
          "system": "http://mybp.nhs.uk/fhir/tags",
          "code": "demo-data",
          "display": "Demonstration Data Only"
        }]
      }
    }
  ]
}
```

### Category C Patients (Newly Detected)

```json
{
  "category_c_samples": [
    {
      "resourceType": "Patient",
      "id": "dummy-patient-c001",
      "identifier": [{
        "use": "usual",
        "type": {
          "coding": [{
            "system": "https://fhir.nhs.uk/Id/nhs-number",
            "code": "NH"
          }]
        },
        "value": "DEMO123456201"
      }],
      "active": true,
      "name": [{
        "use": "official",
        "family": "NewlyDetected",
        "given": ["Emma", "Demo"],
        "prefix": ["Ms"]
      }],
      "gender": "female",
      "birthDate": "1975-12-05",
      "extension": [
        {
          "url": "http://mybp.nhs.uk/fhir/extension/dummy-data-marker",
          "valueBoolean": true
        },
        {
          "url": "http://mybp.nhs.uk/fhir/extension/patient-category",
          "valueString": "C"
        },
        {
          "url": "http://mybp.nhs.uk/fhir/extension/simulation-scenario",
          "valueString": "newly-detected-pharmacy"
        }
      ],
      "meta": {
        "tag": [{
          "system": "http://mybp.nhs.uk/fhir/tags",
          "code": "demo-data",
          "display": "Demonstration Data Only"
        }]
      }
    }
  ]
}
```

### Sample Blood Pressure Readings

```json
{
  "bp_readings_samples": [
    {
      "resourceType": "Observation",
      "id": "dummy-bp-dummy-patient-a001-001",
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
      "subject": {
        "reference": "Patient/dummy-patient-a001",
        "display": "John Demo TestPatient"
      },
      "effectiveDateTime": "2024-01-15T10:30:00+00:00",
      "performer": [{
        "reference": "Organization/dummy-pharmacy-001",
        "display": "Demo Pharmacy - Mill Road"
      }],
      "component": [
        {
          "code": {
            "coding": [{
              "system": "http://loinc.org",
              "code": "8480-6",
              "display": "Systolic blood pressure"
            }]
          },
          "valueQuantity": {
            "value": 135,
            "unit": "mmHg",
            "system": "http://unitsofmeasure.org",
            "code": "mm[Hg]"
          }
        },
        {
          "code": {
            "coding": [{
              "system": "http://loinc.org",
              "code": "8462-4",
              "display": "Diastolic blood pressure"
            }]
          },
          "valueQuantity": {
            "value": 82,
            "unit": "mmHg",
            "system": "http://unitsofmeasure.org",
            "code": "mm[Hg]"
          }
        }
      ],
      "extension": [
        {
          "url": "http://mybp.nhs.uk/fhir/extension/dummy-data-marker",
          "valueBoolean": true
        },
        {
          "url": "http://mybp.nhs.uk/fhir/extension/measurement-context",
          "valueCodeableConcept": {
            "coding": [{
              "system": "http://mybp.nhs.uk/fhir/measurement-context",
              "code": "pharmacy-routine",
              "display": "Routine pharmacy measurement"
            }]
          }
        },
        {
          "url": "http://mybp.nhs.uk/fhir/extension/quality-indicators",
          "extension": [
            {
              "url": "cuff-size-appropriate",
              "valueBoolean": true
            },
            {
              "url": "rest-period-minutes",
              "valueInteger": 5
            },
            {
              "url": "patient-position",
              "valueString": "sitting"
            }
          ]
        }
      ],
      "meta": {
        "profile": ["http://mybp.nhs.uk/fhir/StructureDefinition/MyBP-BloodPressure"],
        "tag": [{
          "system": "http://mybp.nhs.uk/fhir/tags",
          "code": "demo-data",
          "display": "Demonstration Data Only"
        }]
      }
    }
  ]
}
```

### Sample Care Plans

```json
{
  "care_plan_samples": [
    {
      "resourceType": "CarePlan",
      "id": "dummy-careplan-dummy-patient-a001",
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
      "description": "AI-driven care plan for hypertension management using dummy data",
      "subject": {
        "reference": "Patient/dummy-patient-a001"
      },
      "period": {
        "start": "2024-01-01",
        "end": "2024-12-31"
      },
      "created": "2024-01-01T00:00:00+00:00",
      "activity": [
        {
          "detail": {
            "kind": "ServiceRequest",
            "code": {
              "coding": [{
                "system": "http://snomed.info/sct",
                "code": "182836005",
                "display": "Blood pressure monitoring"
              }]
            },
            "status": "in-progress",
            "description": "Monthly blood pressure monitoring at community pharmacy",
            "scheduledPeriod": {
              "start": "2024-01-01",
              "end": "2024-12-31"
            },
            "performer": [{
              "reference": "Organization/dummy-pharmacy-001"
            }]
          }
        },
        {
          "detail": {
            "kind": "MedicationRequest",
            "code": {
              "coding": [{
                "system": "http://snomed.info/sct",
                "code": "432102000",
                "display": "Administration of substance"
              }]
            },
            "status": "in-progress",
            "description": "Amlodipine 5mg daily for blood pressure control",
            "scheduledPeriod": {
              "start": "2024-01-01"
            }
          }
        }
      ],
      "goal": [{
        "reference": "Goal/dummy-bp-target-dummy-patient-a001"
      }],
      "extension": [
        {
          "url": "http://mybp.nhs.uk/fhir/extension/dummy-data-marker",
          "valueBoolean": true
        },
        {
          "url": "http://mybp.nhs.uk/fhir/extension/agent-managed",
          "valueBoolean": true
        },
        {
          "url": "http://mybp.nhs.uk/fhir/extension/care-pathway-stage",
          "valueString": "treatment-optimization"
        }
      ],
      "meta": {
        "tag": [{
          "system": "http://mybp.nhs.uk/fhir/tags",
          "code": "demo-data",
          "display": "Demonstration Data Only"
        }]
      }
    }
  ]
}
```

### Sample Clinical Alerts

```json
{
  "clinical_alert_samples": [
    {
      "resourceType": "Flag",
      "id": "dummy-alert-dummy-patient-a002-001",
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
          "code": "bp-target-not-met",
          "display": "Blood pressure target not achieved after 12 weeks"
        }]
      },
      "subject": {
        "reference": "Patient/dummy-patient-a002"
      },
      "period": {
        "start": "2024-01-15T10:30:00+00:00"
      },
      "encounter": {
        "reference": "Encounter/dummy-encounter-001"
      },
      "author": {
        "reference": "Device/dummy-ai-agent-monitoring"
      },
      "extension": [
        {
          "url": "http://mybp.nhs.uk/fhir/extension/dummy-data-marker",
          "valueBoolean": true
        },
        {
          "url": "http://mybp.nhs.uk/fhir/extension/alert-severity",
          "valueString": "medium"
        },
        {
          "url": "http://mybp.nhs.uk/fhir/extension/triggering-agent",
          "valueString": "monitoring-agent"
        },
        {
          "url": "http://mybp.nhs.uk/fhir/extension/recommended-actions",
          "valueString": "Consider medication titration, specialist referral assessment"
        }
      ],
      "meta": {
        "tag": [{
          "system": "http://mybp.nhs.uk/fhir/tags",
          "code": "demo-data",
          "display": "Demonstration Data Only"
        }]
      }
    }
  ]
}
```

## Data Generation Configuration

### Scenario-Based Data Patterns

```yaml
# data-generation-config.yaml
scenarios:
  stable-management:
    patient_category: "A"
    bp_baseline:
      systolic: 130
      diastolic: 80
    bp_variation: 10
    trend: "stable"
    medication_count: 1
    adherence_rate: 95
    alert_probability: 0.05
    
  treatment-resistant:
    patient_category: "A"
    bp_baseline:
      systolic: 165
      diastolic: 100
    bp_variation: 15
    trend: "resistant"
    medication_count: 3
    adherence_rate: 85
    alert_probability: 0.30
    
  medication-adherence-issues:
    patient_category: "A"
    bp_baseline:
      systolic: 150
      diastolic: 92
    bp_variation: 20
    trend: "variable"
    medication_count: 2
    adherence_rate: 65
    alert_probability: 0.25
    
  red-flag-scenario:
    patient_category: "A"
    bp_baseline:
      systolic: 185
      diastolic: 110
    bp_variation: 25
    trend: "critical"
    medication_count: 2
    adherence_rate: 80
    alert_probability: 0.80
    
  surveillance-routine:
    patient_category: "B"
    bp_baseline:
      systolic: 125
      diastolic: 78
    bp_variation: 8
    trend: "stable"
    medication_count: 0
    adherence_rate: null
    alert_probability: 0.02
    
  newly-detected-pharmacy:
    patient_category: "C"
    bp_baseline:
      systolic: 148
      diastolic: 90
    bp_variation: 12
    trend: "newly_elevated"
    medication_count: 0
    adherence_rate: null
    alert_probability: 0.15

patient_demographics:
  category_a:
    age_range: [45, 75]
    gender_distribution:
      male: 0.45
      female: 0.55
    common_names:
      male: ["John", "Michael", "David", "Robert", "James"]
      female: ["Mary", "Jennifer", "Patricia", "Linda", "Elizabeth"]
      
  category_b:
    age_range: [35, 65]
    gender_distribution:
      male: 0.50
      female: 0.50
      
  category_c:
    age_range: [40, 70]
    gender_distribution:
      male: 0.48
      female: 0.52

bp_measurement_contexts:
  - code: "pharmacy-routine"
    display: "Routine pharmacy measurement"
    weight: 0.40
  - code: "gp-practice-waiting"
    display: "GP practice waiting room"
    weight: 0.25
  - code: "home-monitoring"
    display: "Home monitoring device"
    weight: 0.20
  - code: "community-hub"
    display: "Community health hub"
    weight: 0.15

medication_profiles:
  single_therapy:
    - name: "Amlodipine"
      dose: "5mg"
      frequency: "once daily"
      snomed_code: "108537001"
      
  dual_therapy:
    - name: "Amlodipine"
      dose: "5mg"
      frequency: "once daily"
      snomed_code: "108537001"
    - name: "Ramipril"
      dose: "2.5mg"
      frequency: "once daily"
      snomed_code: "386872004"
      
  triple_therapy:
    - name: "Amlodipine"
      dose: "10mg"
      frequency: "once daily"
      snomed_code: "108537001"
    - name: "Ramipril"
      dose: "5mg"
      frequency: "once daily"
      snomed_code: "386872004"
    - name: "Indapamide"
      dose: "2.5mg"
      frequency: "once daily"
      snomed_code: "387467008"
```

## Data Validation Rules

### Validation Configuration

```python
# validation_rules.py
VALIDATION_RULES = {
    "patient_id_format": r"^dummy-patient-[a-z]\d{3}$",
    "nhs_number_format": r"^DEMO\d{9}$",
    "required_extensions": [
        "http://mybp.nhs.uk/fhir/extension/dummy-data-marker",
        "http://mybp.nhs.uk/fhir/extension/patient-category"
    ],
    "valid_categories": ["A", "B", "C"],
    "valid_scenarios": [
        "newly-diagnosed",
        "treatment-resistant", 
        "medication-adherence-issues",
        "red-flag-scenario",
        "stable-management",
        "lifestyle-intervention",
        "surveillance-routine",
        "surveillance-family-history",
        "newly-detected-pharmacy",
        "newly-detected-health-check"
    ],
    "bp_value_ranges": {
        "systolic": {"min": 70, "max": 250},
        "diastolic": {"min": 40, "max": 150}
    },
    "required_tags": [{
        "system": "http://mybp.nhs.uk/fhir/tags",
        "code": "demo-data",
        "display": "Demonstration Data Only"
    }]
}

def validate_dummy_data_compliance(resource):
    """Validate resource complies with dummy data requirements"""
    errors = []
    
    # Check for dummy data marker
    if not has_dummy_data_marker(resource):
        errors.append("Missing dummy data marker extension")
    
    # Check for demo tag
    if not has_demo_tag(resource):
        errors.append("Missing demo-data tag in meta.tag")
    
    # Resource-specific validation
    if resource.get('resourceType') == 'Patient':
        errors.extend(validate_patient_dummy_compliance(resource))
    elif resource.get('resourceType') == 'Observation':
        errors.extend(validate_observation_dummy_compliance(resource))
    
    return errors
```

---

**These schemas provide comprehensive structure and validation for dummy FHIR data in the My BP demonstration system, ensuring all data is properly marked and formatted for simulation purposes only.**