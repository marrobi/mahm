# My BP Care - Multi-agentic AI Hypertension Management (Demo MVP)

## Executive Summary

This document outlines a demo version of **My BP Care**, a multi-agentic AI tool for hypertension management designed for integration into the NHS App. This MVP demonstrates the orchestration of multiple specialized agents supporting hypertension care, using dummy data and simulated workflows to showcase the system's capabilities.

## Visual Overview

![Hypertension Care Orchestration Agent overview](https://github.com/user-attachments/assets/e52ba838-d85c-430e-91c9-d1748e0c8f1a)

## System Architecture

The system is centered around a **Hypertension Care Orchestration Agent** that coordinates four specialized agents, each handling specific aspects of hypertension management according to NICE guidelines. This simplified architecture reduces complexity while maintaining comprehensive care delivery.

## Agent Architecture Review

Upon reflection, the system could be simplified from 8 specialized agents to 5 core agents by merging related functions:

### Simplified Agent Structure (5 Agents):
1. **Orchestrating Agent** - Central coordination including shared decision-making conversations
2. **Assessment Agent** - Combined BP measurement and diagnostic functions
3. **Lifestyle Agent** - Lifestyle interventions and referrals
4. **Treatment Management Agent** - Combined medication titration and safety monitoring
5. **Red Flag Agent** - Emergency detection and escalation

This simplified structure reduces complexity while maintaining all core functions. The merged agents handle related workflows more efficiently:
- **Assessment Agent** handles the complete measurement-to-diagnosis pathway
- **Treatment Management Agent** provides integrated medication management and monitoring
- **Orchestrating Agent** incorporates patient decision-making as part of its coordination role

## Agent Specifications

### 1. Orchestrating Agent (Central Hub)

**Purpose:** Central coordination agent that follows NICE guidance and escalates to GP by exception

**Key Responsibilities:**
- Coordinates all other agents based on NICE hypertension guidelines
- Makes care pathway decisions
- Escalates complex cases to GP
- Maintains patient care timeline
- Ensures guideline compliance

**Demo Workflow with Dummy Data:**
```
Patient: John Smith (ID: PT001)
Initial BP: 165/95 mmHg (elevated)

1. Receives patient data for individuals due/overdue for BP monitoring per NICE guidelines
2. Analyzes patient data: Age 55, BMI 28, no diabetes, smoker
3. Initiates NICE pathway: Stage 1 hypertension protocol
4. Coordinates with BP Measurement Agent for community monitoring
5. Schedules lifestyle intervention via Lifestyle Agent
6. Sets 4-week review milestone
7. Escalation trigger: If BP >180/110 or patient symptoms worsen
```

**Escalation Protocols:**
- Immediate GP escalation: Severe hypertension (≥180/110), symptoms of end-organ damage
- Routine escalation: No improvement after 3 months of intervention
- Exception handling: Medication contraindications, patient non-compliance

### 2. BP Measurement Agent

**Purpose:** Simulates BP checks via multiple community locations including Lifelight technology, pharmacy partnerships, GP practice waiting rooms, and other accessible venues

**Key Responsibilities:**
- Coordinate community-based BP monitoring
- Validate measurement quality
- Schedule regular monitoring intervals
- Interface with Lifelight app and pharmacy networks

**Demo Workflow with Dummy Data:**
```
Patient: Sarah Johnson (ID: PT002)
Current medication: Amlodipine 5mg

Simulation Steps:
1. Receives monitoring request from Orchestrating Agent
2. Locates nearest BP monitoring location (GP practice waiting room, Boots pharmacy Mill Road - 0.3 miles, or community health hub)
3. Books appointment slot: Tuesday 2:00 PM
4. Simulates measurement: 145/88 mmHg
5. Quality check: Measurement meets NHS standards
6. Reports back to Orchestrating Agent
7. Schedules next measurement in 2 weeks
```

**Dummy Data Sources:**
- BP monitoring locations: 15 pharmacies, 8 GP practices with waiting room devices, 5 community health hubs within 5-mile radius
- Lifelight app integration: 89% measurement success rate
- Average measurement time: 3 minutes

### 3. Diagnosing Agent

**Purpose:** Simulates arrangement of 24-hour ambulatory BP monitoring and provides GP go/no-go recommendations (Note: Patients with existing essential hypertension diagnosis can bypass this agent)

**Key Responsibilities:**
- Arrange ambulatory blood pressure monitoring (ABPM)
- Analyze 24-hour BP patterns
- Confirm hypertension diagnosis
- Provide evidence-based recommendations to GP

**Demo Workflow with Dummy Data:**
```
Patient: Michael Chen (ID: PT003)
Clinic readings: 155/92, 158/95, 152/89 mmHg

Simulation Process:
1. Triggered by 3 elevated clinic readings
2. Arranges ABPM at local hospital (St. Mary's Cardiology)
3. Simulated 24h data:
   - Daytime average: 148/86 mmHg
   - Nighttime average: 135/78 mmHg
   - Nocturnal dipping: 9% (normal)
4. Analysis: Confirms stage 1 hypertension
5. Recommendation: Initiate antihypertensive therapy
6. Sends structured report to GP
```

**Simulated Equipment:**
- ABPM devices: Spacelabs 90217, 90207
- Booking system integration: 72-hour typical wait time
- Data analysis algorithms: NICE-compliant thresholds

### 4. Lifestyle Agent

**Purpose:** Simulates referrals to services for sodium/alcohol reduction, exercise programs, and dietary modifications

**Key Responsibilities:**
- Assess lifestyle risk factors
- Coordinate referrals to lifestyle services
- Track intervention progress
- Provide educational resources

**Demo Workflow with Dummy Data:**
```
Patient: Emma Davis (ID: PT004)
Risk factors: High sodium diet, sedentary lifestyle, moderate alcohol use

Intervention Simulation:
1. Lifestyle assessment questionnaire completed
2. Identifies priorities: Diet (sodium reduction), Exercise, Alcohol
3. Referrals made:
   - NHS Healthier You: Weight management program
   - Local leisure center: Cardiac rehabilitation exercise class
   - Alcohol support: Online NHS alcohol units calculator
4. Educational materials sent: DASH diet guide, home BP monitoring tips
5. 4-week follow-up scheduled
6. Progress tracking: Weight loss 2kg, exercise 3x/week, alcohol reduction 30%
```

**Simulated Services:**
- NHS Healthier You programs: 12 local providers
- Exercise referral schemes: 8 participating gyms/centers
- Dietitian services: 5-week waiting list
- Digital health tools: NHS Food Scanner app, Couch to 5K

### 5. Shared Decision-Making Agent

**Purpose:** Simulates patient support in selecting antihypertensive medications based on preferences and side effects

**Key Responsibilities:**
- Present treatment options to patients
- Explain benefits and risks
- Consider patient preferences and comorbidities
- Support informed decision-making

**Demo Workflow with Dummy Data:**
```
Patient: Robert Wilson (ID: PT005)
Profile: 62 years old, active lifestyle, concerns about fatigue

Decision-Making Simulation:
1. Presents 3 first-line options:
   - ACE inhibitor (Ramipril): Good for active patients, dry cough risk
   - Calcium channel blocker (Amlodipine): Effective, may cause ankle swelling
   - Thiazide diuretic (Indapamide): Cost-effective, increased urination
   
2. Patient priorities identified:
   - Maintain energy levels for cycling
   - Minimize impact on daily activities
   - Cost not a primary concern

3. Educational materials provided:
   - Video explanations of each medication
   - Side effect comparison chart
   - Real patient testimonials

4. Patient choice: ACE inhibitor (Ramipril 2.5mg)
5. Monitoring plan agreed: BP check in 4 weeks
```

**Decision Support Tools:**
- Interactive medication comparison
- Side effect probability calculator
- Patient preference questionnaire
- Educational videos (3-5 minutes each)

### 6. Titration Agent

**Purpose:** Simulates dose adjustment based on mock treatment response

**Key Responsibilities:**
- Monitor treatment response
- Adjust medication doses
- Add combination therapy when needed
- Track side effects and efficacy

**Demo Workflow with Dummy Data:**
```
Patient: Lisa Thompson (ID: PT006)
Initial treatment: Amlodipine 5mg daily
4-week BP reading: 158/90 mmHg (target <140/90)

Titration Simulation:
1. Analyzes treatment response: Partial response (20mmHg reduction)
2. Checks for side effects: None reported
3. Reviews NICE guidance: Increase dose or add second agent
4. Patient consultation simulated:
   - Current dose tolerance: Good
   - Willingness to increase: Yes
5. Decision: Increase Amlodipine to 10mg daily
6. New monitoring schedule: 4 weeks
7. Target reassessment: If not at target, consider ACE inhibitor addition
```

**Simulated Treatment Responses:**
- 60% achieve target with first agent optimization
- 25% require dual therapy
- 15% need triple therapy or specialist referral

### 7. Monitoring Agent

**Purpose:** Simulates U&E (Urea and Electrolytes) monitoring and other safety parameters

**Key Responsibilities:**
- Schedule routine blood tests
- Monitor for medication-related complications
- Alert to abnormal results
- Coordinate with GP for result review

**Demo Workflow with Dummy Data:**
```
Patient: David Brown (ID: PT007)
Medication: Ramipril 5mg, started 8 weeks ago

Monitoring Simulation:
1. Triggered monitoring schedule: ACE inhibitor = U&E at 2 weeks, then 12 weeks
2. Simulated blood results:
   - Creatinine: 95 μmol/L (baseline 88 μmol/L)
   - eGFR: 72 mL/min/1.73m² (baseline 78)
   - Potassium: 4.2 mmol/L (normal range)
   - Sodium: 140 mmol/L (normal)
3. Analysis: Slight creatinine rise (<20%) - acceptable
4. Action: Continue current therapy
5. Next monitoring: 12 weeks
6. Alert thresholds: Creatinine >30% increase, K+ >5.5mmol/L
```

**Monitoring Protocols:**
- ACE inhibitors: U&E at 2 weeks, 12 weeks, then annually
- Diuretics: U&E at 4 weeks, then every 6 months
- All patients: Annual lipid profile, HbA1c if diabetic

### 8. Red Flag Agent

**Purpose:** Simulates red flag detection and escalation per NICE guidance

**Key Responsibilities:**
- Continuous monitoring for warning signs
- Immediate escalation protocols
- Emergency pathway activation
- Communication with emergency services

**Demo Workflow with Dummy Data:**
```
Patient: Grace Miller (ID: PT008)
Routine check reveals: BP 195/115 mmHg, headache, visual disturbance

Red Flag Simulation:
1. Automated red flag detection:
   - Severe hypertension (≥180/110)
   - Symptoms suggesting hypertensive emergency
   - Patient age >65 (increased risk)

2. Immediate actions triggered:
   - Priority GP appointment (same day)
   - Patient safety advice: Avoid driving, rest
   - Hospital alert if GP unavailable
   - Family notification protocol

3. Escalation pathway:
   - GP assessment within 2 hours
   - Consider hospital admission
   - Antihypertensive therapy review
   - 24-hour follow-up mandatory

4. Documentation: Incident logged for quality improvement
```

**Red Flag Triggers:**
- BP ≥180/110 mmHg with symptoms
- Signs of end-organ damage
- Medication non-compliance >7 days
- Patient-reported chest pain, shortness of breath
- Pregnancy with elevated BP

## User Journey Examples

### Journey 1: New Patient Onboarding
```
Patient: Tom Richards, 58, referred by GP risk tool

Day 1: 
- Orchestrating Agent receives referral
- Initial assessment questionnaire sent via NHS App
- BP measurement scheduled at local pharmacy

Day 3:
- BP measurement completed: 168/96 mmHg
- Lifestyle Agent assessment initiated
- Educational materials provided

Day 7:
- Lifestyle plan agreed: Diet modification, exercise program
- Shared Decision-Making Agent consultation scheduled

Day 14:
- Medication decision made: Ramipril 2.5mg
- Monitoring plan established
- 4-week review booked
```

### Journey 2: Medication Titration
```
Patient: Jennifer Lee, 45, on treatment for 6 weeks

Week 6:
- BP Measurement Agent: 152/88 mmHg (not at target)
- Titration Agent analysis: Partial response
- Dose increase recommended

Week 7:
- Shared Decision-Making consultation
- Patient agrees to dose increase
- Ramipril increased to 5mg

Week 10:
- Monitoring Agent: U&E check normal
- Continue current therapy

Week 14:
- BP check: 138/82 mmHg (at target)
- Monitoring schedule adjusted to monthly
```

### Journey 3: Red Flag Escalation
```
Patient: Alan Murphy, 72, established patient

Day 1:
- Routine BP check: 188/112 mmHg
- Patient reports headache, nausea
- Red Flag Agent immediately activated

Day 1 (within 30 minutes):
- GP surgery contacted
- Urgent appointment arranged
- Patient advised to avoid driving

Day 1 (2 hours later):
- GP assessment completed
- Hospital referral made
- Antihypertensive therapy intensified

Day 2:
- Follow-up BP: 165/95 mmHg
- Hospital discharge with new medication plan
- Close monitoring protocol initiated
```

## Agent Interaction Protocols

### Standard Workflow Communication
1. **Orchestrating Agent** receives patient data and determines care pathway
2. **BP Measurement Agent** provides monitoring data to Orchestrating Agent
3. **Orchestrating Agent** shares results with relevant specialist agents
4. **Specialist Agents** (Lifestyle, Titration, Monitoring) provide recommendations
5. **Orchestrating Agent** consolidates recommendations and updates care plan
6. **Red Flag Agent** operates continuously, can interrupt any workflow

### Emergency Communication
- **Red Flag Agent** has priority communication channel
- Can directly contact GP, emergency services, and patient
- All other agents receive emergency status updates
- Normal workflows suspended during emergency protocols

### Data Sharing Protocols
- All agents access centralized patient record (demo database)
- Updates logged with timestamps and agent ID
- GP receives weekly summary reports
- Patient receives real-time updates via NHS App

## Demo Data Sources

### Patient Profiles (Dummy Data)
- 50 simulated patient records
- Age range: 35-75 years
- Mix of ethnicities, genders, and risk factors
- Various stages of hypertension treatment

### Clinical Data
- BP readings: Normal distribution around realistic values
- Laboratory results: Within normal ranges with occasional abnormalities
- Medication responses: Based on clinical trial efficacy data

### Service Provider Data
- 15 pharmacy locations with realistic wait times
- 5 hospital services for ABPM
- 10 lifestyle intervention providers
- Typical NHS waiting times applied

## Success Metrics (Simulated)

### Clinical Outcomes
- 75% of patients achieve target BP within 12 weeks
- 90% attend scheduled appointments
- 95% medication adherence rate
- 0.5% emergency escalations

### Operational Metrics
- Average time to first intervention: 48 hours
- GP escalation rate: 15% of cases
- Patient satisfaction score: 4.2/5
- System uptime: 99.5%

## Future Development Considerations

### Integration Requirements (Not Implemented in Demo)
- NHS App technical integration
- GP practice system connectivity
- Hospital electronic health records
- Pharmacy management systems

### Compliance and Governance (Excluded from Demo)
- Data protection and GDPR compliance
- Clinical governance frameworks
- Professional liability considerations
- Medical device regulations

### Scalability Planning
- Multi-region deployment
- Performance optimization
- Disaster recovery protocols
- Capacity planning models

## Demonstration Scenarios

### Scenario A: Complete Care Pathway
**Duration:** 20 minutes
**Participants:** Demo presenter, simulated patient journey
**Focus:** End-to-end workflow from referral to treatment optimization

### Scenario B: Emergency Escalation
**Duration:** 10 minutes
**Participants:** Red Flag Agent demonstration
**Focus:** Crisis detection and rapid response protocols

### Scenario C: Multi-agent Coordination
**Duration:** 15 minutes
**Participants:** All agents in coordinated response
**Focus:** Complex case requiring multiple interventions

## Technical Architecture (High-Level)

### Agent Framework
- Each agent implemented as microservice
- RESTful API communication
- Event-driven architecture for real-time responses
- Centralized logging and monitoring

### Demo Database Schema
```
Patients: ID, demographics, medical history, current medications
BP_Readings: Patient_ID, timestamp, systolic, diastolic, location
Interventions: Patient_ID, agent_ID, type, status, outcome
Escalations: Patient_ID, trigger, severity, resolution
Appointments: Patient_ID, service_type, date, status
```

### User Interface (NHS App Integration Points)
- Patient dashboard with latest readings
- Appointment booking interface
- Educational resource library
- Direct communication with care team
- Emergency contact buttons

## Conclusion

This MVP demonstrates a comprehensive multi-agentic approach to hypertension management that could significantly improve patient outcomes while reducing GP workload. The demo version showcases the potential for AI-driven healthcare coordination while maintaining clinical safety through appropriate escalation protocols.

The simulated workflows and dummy data provide a realistic foundation for stakeholder evaluation and future development planning, focusing on the core value proposition without the complexity of full system integration.

---

*This document represents a demo version using simulated data and workflows. No real patient data or live clinical systems are involved in this demonstration.*