# My BP - Technical Architecture for Azure AI Foundry

**⚠️ SIMULATION ONLY - NOT FOR CLINICAL USE ⚠️**

## Overview

The My BP hypertension management system leverages **Azure AI Foundry Connected Agents** to coordinate 9 specialized AI agents for comprehensive care workflows using dummy patient data via Azure API for FHIR R4.

## Architecture Design

### Connected Agents Approach
Using Azure AI Foundry's Connected Agents service provides:
- **Natural language routing** between specialized agents without custom orchestration
- **Main orchestrating agent** that intelligently delegates tasks to purpose-built sub-agents
- **Built-in monitoring** and traceability for clinical safety
- **No-code configuration** via Azure AI Foundry portal

### Core Agent Roles
1. **Main Orchestrating Agent** - Central coordination with clinical safety prioritization
2. **BP Measurement Agent** - Community monitoring coordination  
3. **Diagnosing Agent** - ABPM arrangement and diagnostic workflows
4. **Lifestyle Agent** - Culturally-sensitive lifestyle interventions
5. **Shared Decision-Making Agent** - Patient-centered treatment planning
6. **Titration Agent** - NICE-compliant medication optimization
7. **Monitoring Agent** - Safety monitoring and lab coordination
8. **Medication Adherence Agent** - Behavioral support interventions
9. **Red Flag Agent** - Emergency detection and escalation

### Azure Infrastructure
- **Azure AI Foundry workspace** with connected agents configuration
- **Azure API for FHIR R4** with comprehensive dummy data patterns
- **Azure Monitor + Application Insights** for clinical safety monitoring
- **Azure Key Vault** for secure configuration management

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                           Azure AI Foundry Workspace                │
├─────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │                Main Orchestrating Agent                         │ │
│  │           (Connected Agents Hub - Natural Language Routing)     │ │
│  └─────────────────────────────────────────────────────────────────┘ │
│                                   │                                  │
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │                    Specialized Agent Network                    │ │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐│ │
│  │  │ BP Measure  │ │ Diagnosing  │ │ Lifestyle   │ │ Shared      ││ │
│  │  │ Agent       │ │ Agent       │ │ Agent       │ │ Decision    ││ │
│  │  └─────────────┘ └─────────────┘ └─────────────┘ │ Agent       ││ │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ └─────────────┘│ │
│  │  │ Titration   │ │ Monitoring  │ │ Medication  │ ┌─────────────┐│ │
│  │  │ Agent       │ │ Agent       │ │ Adherence   │ │ Red Flag    ││ │
│  │  └─────────────┘ └─────────────┘ │ Agent       │ │ Agent       ││ │
│  │                                  └─────────────┘ └─────────────┘│ │
│  └─────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                    ┌──────────────┴──────────────┐
                    │                             │
┌─────────────────────────────────┐  ┌─────────────────────────────────┐
│        Azure API for FHIR       │  │     Azure Monitor + AppInsights │
│                                 │  │                                 │
│  ┌─────────────────────────────┐│  │  ┌─────────────────────────────┐│
│  │      Dummy Patient Data     ││  │  │    Clinical Safety Alerts   ││
│  │   (Category A, B, C)        ││  │  │                             ││
│  │                             ││  │  │  ┌─────────────────────────┐││
│  │  • Patient Resources        ││  │  │  │   Audit Trail Logging   │││
│  │  • Observation (BP)         ││  │  │  └─────────────────────────┘││
│  │  • MedicationRequest        ││  │  │                             ││
│  │  • DiagnosticReport         ││  │  │  ┌─────────────────────────┐││
│  │  • CarePlan                 ││  │  │  │  Real-time Monitoring   │││
│  │  • Flag (Red Flags)         ││  │  │  └─────────────────────────┘││
│  └─────────────────────────────┘│  └─────────────────────────────────┘
└─────────────────────────────────┘
```

## Dummy Data Strategy

### Patient Categories (FHIR R4 Compliant)
- **Category A**: Known hypertension patients with treatment history
- **Category B**: Surveillance patients with borderline readings  
- **Category C**: Newly detected hypertension requiring full assessment

### Safety-First Design
- Real-time red flag detection with <30 second response times
- Multi-tier escalation protocols (immediate/urgent/routine)
- Comprehensive audit trails for all clinical decisions
- Circuit breaker patterns and fail-safe mechanisms

## Agent Communication & API Specifications

### Connected Agents Communication Pattern
Azure AI Foundry Connected Agents use natural language routing, eliminating the need for custom API orchestration. Each agent communicates through the main orchestrating agent using standardized message formats.

### Core Message Schema
```json
{
  "messageId": "uuid",
  "timestamp": "ISO8601",
  "sourceAgent": "agent_name",
  "targetAgent": "agent_name",
  "messageType": "request|response|alert|escalation",
  "patientId": "fhir_patient_id",
  "priority": "immediate|urgent|routine",
  "content": {
    "clinicalContext": {},
    "data": {},
    "action": "",
    "reasoning": ""
  },
  "auditTrail": {
    "userId": "system_user",
    "sessionId": "uuid",
    "complianceFlags": []
  }
}
```

### Escalation Flow Specification

#### Red Flag Detection & Escalation
```
1. ANY Agent → Red Flag Agent
   Trigger: Clinical indicators above threshold
   Response Time: <30 seconds
   
2. Red Flag Agent → Orchestrating Agent
   Classification: immediate|urgent|routine
   
3. Orchestrating Agent → Monitoring Agent
   Action: Alert healthcare team
   
4. Circuit Breaker Pattern
   If: No response within 2 minutes
   Then: Automatic escalation to next tier
```

#### Multi-Tier Escalation Protocols
- **Immediate (0-5 minutes)**: BP >180/120, severe symptoms, drug interactions
- **Urgent (5-60 minutes)**: BP 160-179/100-119, missed critical doses
- **Routine (1-24 hours)**: Lifestyle adherence, routine monitoring

## Agent Implementation Guidelines

### 1. Main Orchestrating Agent
**Purpose**: Central coordination and clinical safety prioritization

**Inputs**:
- Patient context from FHIR (Patient, Observation, MedicationRequest resources)
- Agent responses and status updates
- External triggers (new BP readings, lab results)

**Core Logic**:
- Route requests to appropriate specialized agents using natural language
- Maintain patient care pathway state
- Prioritize clinical safety over efficiency
- Implement NICE guideline compliance checks

**Outputs**:
- Task assignments to specialized agents
- Care plan updates to FHIR CarePlan resource
- Safety alerts and escalations

**State Management**: 
- Current care pathway stage per patient
- Active agent assignments
- Pending escalations and timeouts

### 2. BP Measurement Agent  
**Purpose**: Community-based blood pressure monitoring coordination

**Inputs**:
- Patient location and preferences
- Requested measurement frequency
- Previous BP readings (FHIR Observation resources)

**Core Logic**:
- Coordinate community pharmacy BP checks
- Schedule and track measurement compliance
- Validate BP reading quality and patterns
- Detect measurement adherence issues

**Outputs**:
- Pharmacy booking confirmations
- BP measurement reminders
- Measurement adherence reports
- Quality flags for questionable readings

**State Management**:
- Scheduled measurements per patient
- Measurement history and patterns
- Pharmacy availability and preferences

### 3. Diagnosing Agent
**Purpose**: ABPM arrangement and diagnostic workflows

**Inputs**:
- Initial BP readings requiring confirmation
- Patient demographic and risk factors
- Previous diagnostic history

**Core Logic**:
- Apply NICE diagnostic criteria (clinic BP, ABPM, HBPM)
- Coordinate 24-hour ABPM scheduling
- Interpret diagnostic results
- Confirm or rule out hypertension diagnosis

**Outputs**:
- ABPM booking requests
- Diagnostic recommendations to GP
- Updated patient diagnosis status
- FHIR DiagnosticReport resources

**State Management**:
- Diagnostic pathway progress per patient
- ABPM availability and scheduling
- Pending diagnostic confirmations

### 4. Lifestyle Agent
**Purpose**: Culturally-sensitive lifestyle interventions

**Inputs**:
- Patient demographic and cultural profile
- Current lifestyle factors (BMI, exercise, diet, alcohol)
- Available local services and programs

**Core Logic**:
- Assess lifestyle risk factors
- Match patients to culturally appropriate interventions
- Coordinate referrals to local services
- Track lifestyle goal progress

**Outputs**:
- Lifestyle assessment reports
- Service referral requests
- Goal setting and tracking plans
- Progress updates to care team

**State Management**:
- Active lifestyle goals per patient
- Service referral status
- Progress tracking metrics

### 5. Shared Decision-Making Agent
**Purpose**: Patient-centered treatment planning

**Inputs**:
- Available treatment options
- Patient preferences and concerns
- Side effect profiles and contraindications
- Cultural and accessibility considerations

**Core Logic**:
- Present treatment options in accessible formats
- Support informed decision-making process
- Document patient preferences and decisions
- Coordinate with prescribing workflows

**Outputs**:
- Treatment option presentations
- Decision support tools
- Patient preference documentation
- Prescribing recommendations

**State Management**:
- Decision-making session progress
- Patient preference profiles
- Treatment option evaluations

### 6. Titration Agent
**Purpose**: NICE-compliant medication optimization

**Inputs**:
- Current medication regimen (FHIR MedicationRequest)
- Recent BP readings and target levels
- Side effects and tolerability data
- Lab results (U&E, creatinine)

**Core Logic**:
- Apply NICE titration algorithms
- Assess medication response patterns
- Identify optimization opportunities
- Generate dose adjustment recommendations

**Outputs**:
- Dose adjustment recommendations
- Medication change proposals
- Updated MedicationRequest resources
- Titration progress reports

**State Management**:
- Titration schedules per patient
- Medication response tracking
- Optimization targets and progress

### 7. Monitoring Agent
**Purpose**: Safety monitoring and lab coordination

**Inputs**:
- Lab test schedules and protocols
- Abnormal result thresholds
- Medication monitoring requirements
- Patient risk stratification

**Core Logic**:
- Schedule routine monitoring (U&E, creatinine, eGFR)
- Detect abnormal results requiring action
- Coordinate medication safety monitoring
- Generate monitoring alerts and recommendations

**Outputs**:
- Lab test scheduling requests
- Abnormal result alerts
- Monitoring protocol adherence reports
- Safety recommendations

**State Management**:
- Monitoring schedules per patient
- Pending lab results
- Safety alert status

### 8. Medication Adherence Agent
**Purpose**: Behavioral support interventions

**Inputs**:
- Prescription adherence data
- Patient-reported barriers
- Behavioral intervention history
- Cultural and accessibility factors

**Core Logic**:
- Assess adherence patterns and barriers
- Implement behavioral intervention strategies
- Coordinate pharmacy support services
- Track adherence improvement

**Outputs**:
- Adherence assessment reports
- Intervention recommendations
- Pharmacy support requests
- Adherence progress tracking

**State Management**:
- Adherence patterns per patient
- Active intervention programs
- Barrier identification and management

### 9. Red Flag Agent
**Purpose**: Emergency detection and escalation

**Inputs**:
- Real-time clinical data streams
- Predefined red flag criteria
- Escalation protocols and contacts
- Patient emergency preferences

**Core Logic**:
- Continuous monitoring for red flag conditions
- Immediate classification and prioritization
- Automated escalation to appropriate contacts
- Documentation of emergency responses

**Outputs**:
- Immediate safety alerts
- Emergency escalation notifications
- Clinical team notifications
- Emergency response documentation

**State Management**:
- Active monitoring per patient
- Escalation status tracking
- Emergency contact management

## Detailed Dummy Data Patterns

### FHIR R4 Resource Examples for Clinical Scenarios

#### Red Flag Scenario - Hypertensive Crisis
```json
{
  "resourceType": "Observation",
  "id": "bp-crisis-001",
  "status": "final",
  "category": [{"coding": [{"code": "vital-signs"}]}],
  "code": {"coding": [{"code": "85354-9", "display": "Blood pressure"}]},
  "subject": {"reference": "Patient/dummy-patient-001"},
  "effectiveDateTime": "2024-01-15T14:30:00Z",
  "component": [
    {"code": {"coding": [{"code": "8480-6", "display": "Systolic BP"}]}, "valueQuantity": {"value": 185, "unit": "mmHg"}},
    {"code": {"coding": [{"code": "8462-4", "display": "Diastolic BP"}]}, "valueQuantity": {"value": 125, "unit": "mmHg"}}
  ],
  "interpretation": [{"coding": [{"code": "H", "display": "High"}]}],
  "extension": [
    {"url": "http://example.org/dummy-data-marker", "valueBoolean": true},
    {"url": "http://example.org/red-flag-trigger", "valueBoolean": true}
  ]
}
```

#### Medication Titration Scenario - ACE Inhibitor Optimization
```json
{
  "resourceType": "MedicationRequest",
  "id": "ace-titration-001",
  "status": "active",
  "intent": "order",
  "medicationCodeableConcept": {"coding": [{"code": "314076", "display": "Lisinopril 10mg"}]},
  "subject": {"reference": "Patient/dummy-patient-002"},
  "dosageInstruction": [{
    "text": "10mg once daily, increase to 20mg if BP not controlled",
    "timing": {"repeat": {"frequency": 1, "period": 1, "periodUnit": "d"}},
    "doseAndRate": [{"doseQuantity": {"value": 10, "unit": "mg"}}]
  }],
  "extension": [
    {"url": "http://example.org/dummy-data-marker", "valueBoolean": true},
    {"url": "http://example.org/titration-eligible", "valueBoolean": true}
  ]
}
```

#### ABPM Diagnostic Scenario
```json
{
  "resourceType": "DiagnosticReport",
  "id": "abpm-report-001",
  "status": "final",
  "category": [{"coding": [{"code": "cardiology"}]}],
  "code": {"coding": [{"code": "77938-0", "display": "24 hour blood pressure monitoring"}]},
  "subject": {"reference": "Patient/dummy-patient-003"},
  "effectiveDateTime": "2024-01-10T00:00:00Z",
  "result": [
    {"reference": "Observation/abpm-day-average-001"},
    {"reference": "Observation/abpm-night-average-001"}
  ],
  "conclusion": "Daytime average 145/92 mmHg, nighttime average 135/85 mmHg. Confirmed stage 1 hypertension.",
  "extension": [
    {"url": "http://example.org/dummy-data-marker", "valueBoolean": true},
    {"url": "http://example.org/diagnostic-confirmation", "valueString": "stage-1-hypertension"}
  ]
}
```

#### Lifestyle Intervention Tracking
```json
{
  "resourceType": "CarePlan",
  "id": "lifestyle-plan-001",
  "status": "active",
  "intent": "plan",
  "subject": {"reference": "Patient/dummy-patient-004"},
  "activity": [
    {
      "detail": {
        "code": {"coding": [{"code": "226029", "display": "Exercise therapy"}]},
        "status": "in-progress",
        "description": "30 minutes moderate exercise 5 days per week",
        "goal": [{"reference": "Goal/exercise-goal-001"}]
      }
    },
    {
      "detail": {
        "code": {"coding": [{"code": "226030", "display": "Dietary modification"}]},
        "status": "in-progress", 
        "description": "Reduce sodium intake to <2.3g daily",
        "goal": [{"reference": "Goal/sodium-goal-001"}]
      }
    }
  ],
  "extension": [
    {"url": "http://example.org/dummy-data-marker", "valueBoolean": true},
    {"url": "http://example.org/cultural-adaptation", "valueString": "south-asian-dietary-preferences"}
  ]
}
```

#### Patient Risk Stratification Categories
```json
{
  "resourceType": "Patient",
  "id": "dummy-patient-category-a",
  "active": true,
  "name": [{"family": "TestPatient", "given": ["Category-A"]}],
  "gender": "female",
  "birthDate": "1965-05-15",
  "extension": [
    {"url": "http://example.org/dummy-data-marker", "valueBoolean": true},
    {"url": "http://example.org/patient-category", "valueString": "known-hypertension"},
    {"url": "http://example.org/risk-stratification", "valueString": "high-risk"},
    {"url": "http://example.org/ethnicity", "valueString": "south-asian"}
  ]
}
```

### Clinical Safety Monitoring Data Patterns

#### Emergency Flag Resource
```json
{
  "resourceType": "Flag",
  "id": "red-flag-001",
  "status": "active",
  "category": [{"coding": [{"code": "safety", "display": "Safety"}]}],
  "code": {"coding": [{"code": "red-flag", "display": "Clinical Red Flag"}]},
  "subject": {"reference": "Patient/dummy-patient-001"},
  "period": {"start": "2024-01-15T14:30:00Z"},
  "author": {"reference": "Device/red-flag-agent"},
  "extension": [
    {"url": "http://example.org/dummy-data-marker", "valueBoolean": true},
    {"url": "http://example.org/escalation-level", "valueString": "immediate"},
    {"url": "http://example.org/trigger-reason", "valueString": "bp-crisis-185-125"}
  ]
}
```

## Monitoring & Audit Trail Specifications

### Clinical Safety Monitoring Framework
- **Real-time Agent Performance Tracking**: Monitor response times, error rates, and decision quality
- **Clinical Decision Audit Logs**: Complete traceability of all AI-driven clinical recommendations
- **Red Flag Detection Monitoring**: <30 second response time SLA with automated escalation
- **FHIR Compliance Validation**: Continuous validation of data format and dummy data markers

### Azure Monitor Configuration
```yaml
# Application Insights Configuration
monitoring:
  components:
    - name: "MainOrchestrator"
      metrics: ["response_time", "escalation_triggers", "safety_alerts"]
    - name: "RedFlagAgent" 
      metrics: ["detection_time", "false_positives", "escalation_success"]
    - name: "AllAgents"
      metrics: ["message_throughput", "error_rates", "fhir_compliance"]
  
  alerts:
    - name: "RedFlagResponseTime"
      condition: "response_time > 30_seconds"
      action: "immediate_escalation"
    - name: "AgentCommunicationFailure"
      condition: "error_rate > 5%"
      action: "circuit_breaker_activation"
```

### Audit Trail Data Structure
```json
{
  "auditEvent": {
    "resourceType": "AuditEvent",
    "type": {"code": "clinical-decision"},
    "action": "C",
    "recorded": "2024-01-15T14:30:00Z",
    "agent": [
      {"who": {"reference": "Device/titration-agent"}},
      {"who": {"reference": "Patient/dummy-patient-001"}}
    ],
    "entity": [
      {"what": {"reference": "MedicationRequest/ace-titration-001"}},
      {"what": {"reference": "Observation/bp-reading-001"}}
    ],
    "extension": [
      {"url": "http://example.org/decision-reasoning", "valueString": "BP target not met, dose increase recommended per NICE guidance"},
      {"url": "http://example.org/safety-checks", "valueString": "No contraindications, U&E within normal limits"},
      {"url": "http://example.org/dummy-data-marker", "valueBoolean": true}
    ]
  }
}
```

## MVP Implementation Phases

### Phase 1: Foundation Setup (Weeks 1-2)
- Deploy Azure AI Foundry workspace and connected agents
- Configure Azure API for FHIR with dummy data schemas
- Implement basic orchestrating agent with safety protocols
- Set up monitoring and alerting infrastructure

### Phase 2: Core Agent Development (Weeks 3-4)
- Develop and deploy 9 specialized connected agents
- Configure natural language routing between agents
- Implement FHIR R4 data integration patterns
- Test agent coordination and escalation workflows

### Phase 3: Safety & Monitoring (Weeks 5-6)
- Deploy comprehensive clinical safety monitoring
- Implement red flag detection and escalation protocols
- Configure audit trails and compliance reporting
- Conduct safety testing with dummy patient scenarios

### Phase 4: MVP Demo Preparation (Weeks 7-8)
- Complete dummy data population for all patient categories
- Implement demonstration workflows and user interfaces
- Conduct end-to-end testing with realistic clinical scenarios
- Prepare documentation and training materials

## Key Success Criteria

- **Clinical Safety**: Zero missed red flags in dummy data scenarios
- **Agent Coordination**: <5 second routing between connected agents
- **Data Compliance**: 100% FHIR R4 compliance with proper dummy data marking
- **Monitoring Coverage**: Complete audit trail for all clinical decisions
- **Scalability**: Support for 1000+ concurrent dummy patient interactions

## Risk Mitigation

- **Data Safety**: All resources marked with dummy data extensions
- **Clinical Safety**: Mandatory escalation to human oversight for critical decisions
- **System Reliability**: Circuit breakers and fail-safe mechanisms throughout
- **Compliance**: Continuous validation of FHIR R4 compliance and dummy data usage

---

*This document provides a high-level technical architecture for demonstration purposes only. All patient data references are dummy/simulated for testing and development.*