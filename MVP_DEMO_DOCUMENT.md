# My BP - Multi-agentic AI Hypertension Management (Demo MVP)

**⚠️ SIMULATION ONLY - NOT FOR CLINICAL USE ⚠️**

*This is a demonstration system using dummy data only. This tool does not have medical device approval and is not intended for real-world clinical decision-making. All patient data, clinical scenarios, and outcomes shown are simulated for demonstration purposes only.*

## Executive Summary

This document outlines a demo version of **My BP**, a multi-agentic AI tool for hypertension management designed for integration into the NHS App. This system demonstrates the potential of multi-agentic AI systems while adhering to Microsoft's Trustworthy AI principles of fairness, reliability, safety, privacy, inclusiveness, transparency, and accountability. As an NHS service, My BP would be **entirely free of charge to patients at the point of use**.

**Primary Objectives:**
- **Clinical safety as the number one priority**
- Improve adherence to NICE guidelines, particularly for people in lower socioeconomic groups and other marginalised communities
- Reduce administrative workload for GP practices
- Support digitally excluded patients through additional accessible tools (simple interfaces, hybrid digital/non-digital options, accessibility support) or by freeing up clinician time to provide enhanced face-to-face care for those who cannot or will not use digital systems

This MVP demonstrates the orchestration of multiple specialized agents supporting hypertension care, using dummy data and simulated workflows to showcase the system's capabilities. **All data shown is simulated for demonstration purposes only - this is not a real-world clinical tool.**

## Visual Overview

![Hypertension Care Orchestration Agent overview](https://github.com/user-attachments/assets/e52ba838-d85c-430e-91c9-d1748e0c8f1a)

## System Architecture

The system is centred around a **Hypertension Care Orchestration Agent** that coordinates eight specialized agents, each handling specific aspects of hypertension management according to NICE guidelines. This comprehensive architecture ensures all critical functions are covered while maintaining coordinated care delivery.

## Agent Structure
1. **Orchestrating Agent** - Central coordination and care pathway management
2. **BP Measurement Agent** - Community-based blood pressure monitoring
3. **Diagnosing Agent** - ABPM arrangement and diagnostic confirmation
4. **Lifestyle Agent** - Lifestyle interventions and referrals
5. **Shared Decision-Making Agent** - Patient-centred treatment decisions
6. **Titration Agent** - Medication dose optimization
7. **Monitoring Agent** - Safety monitoring and blood test coordination
8. **Medication Adherence Agent** - Adherence support and compliance monitoring
9. **Red Flag Agent** - Emergency detection and escalation

This comprehensive structure ensures all aspects of hypertension management are covered with specialized agents for each critical function, while maintaining coordination through the central Orchestrating Agent.

## Patient Categories and Pathways

The system manages three distinct patient categories, each with different entry points and workflows:

### Category A: Known Hypertension Patients
**Profile:** Individuals with established essential hypertension diagnosis starting system management
- Existing diagnosis confirmed through previous clinical assessment
- May be treatment-naive or already on antihypertensive therapy
- Require ongoing medication management and monitoring

**System Entry Point:** Treatment Management and Monitoring Phase
- **Bypass:** Diagnostic Agent (already diagnosed)
- **Primary Agents:** Orchestrating Agent → Treatment Management Agent → Monitoring Agent
- **Supporting Agents:** Lifestyle Agent, Red Flag Agent as needed

**Example Workflow:**
```
Patient: Sarah Thompson, 52, diagnosed hypertension 7 years ago
Entry: Automated EHR system trawl identifying patients with essential hypertension and no exclusion criteria
Pathway: Orchestrating Agent → Shared Decision-Making → Medication review → Monitoring schedule
```

### Category B: Normotensive Surveillance Patients  
**Profile:** Individuals with normal BP requiring periodic monitoring per NICE guidelines
- Previous normal readings but due for routine screening
- May have cardiovascular risk factors requiring surveillance
- Family history or lifestyle factors warranting closer monitoring

**System Entry Point:** Routine Monitoring and Surveillance
- **Primary Agents:** Orchestrating Agent → BP Measurement Agent → Lifestyle Agent (preventive)
- **Escalation Path:** If elevated readings detected → Category C diagnostic pathway
- **Monitoring Frequency:** Annual or per NICE risk stratification

**Example Workflow:**
```
Patient: James Wilson, 45, 5-yearly BP check due per NICE guidelines
Entry: NHS Health Check programme or practice recall system
Pathway: BP Measurement → Normal reading → Lifestyle assessment → 5-year recall
Escalation: If ≥140/90 → Diagnostic pathway activated
```

### Category C: Newly Detected Elevated BP Patients
**Profile:** Individuals with newly identified elevated blood pressure readings requiring diagnostic workup
- Elevated readings during routine monitoring or opportunistic screening
- No previous hypertension diagnosis
- Require confirmation through ambulatory monitoring per NICE guidelines

**System Entry Point:** Diagnostic and Assessment Phase
- **Primary Agents:** Orchestrating Agent → BP Measurement Agent → Diagnosing Agent
- **Progression Path:** Upon diagnosis → Transition to Category A workflows
- **Timeline:** NICE-compliant diagnostic pathway (typically 4-12 weeks)

**Example Workflow:**
```
Patient: Emma Clarke, 38, elevated reading at NHS Health Check
Entry: NHS Health Check programme or community BP screening programme
Pathway: Repeat measurements → ABPM arrangement → Diagnosis confirmation → Treatment initiation
Transition: Upon hypertension diagnosis → Category A management
```

### Pathway Decision Matrix

| BP Reading | Previous History | System Response | Patient Category |
|------------|------------------|-----------------|------------------|
| <140/90    | No hypertension  | Routine surveillance | Category B |
| <140/90    | Known hypertension | Continue monitoring | Category A |
| 140-179/90-109 | No hypertension | Diagnostic pathway | Category C |
| 140-179/90-109 | Known hypertension | Assess treatment response | Category A |
| ≥180/110   | Any | Red Flag escalation | All categories |

### Inter-Category Transitions

**B → C:** Normotensive patient develops elevated readings
- Automatic pathway escalation
- Diagnostic workup initiated
- Temporary surveillance intensification

**C → A:** Newly diagnosed patient confirmed with hypertension
- Seamless transition to treatment management
- Diagnostic data carried forward
- Treatment pathway activation

**A → B:** Treated patient achieves sustained normal readings
- Rare transition requiring specialist review
- Medication withdrawal protocols
- Enhanced surveillance maintenance

## Agent Specifications

### 1. Orchestrating Agent (Central Hub)

**Purpose:** Central coordination agent that prioritises clinical safety above all else, follows NICE guidance strictly, and escalates to GP by exception

**Clinical Safety Priority:** This agent is designed to be paranoid about clinical safety. If at any point something could be dangerous or "not quite right", it must refer to the GP with the appropriate degree of urgency. It serves as guard rails: if everything fits within NICE guidelines, that's acceptable, but the moment something goes awry, it must refer to the GP.

**Key Responsibilities:**
- Coordinates all other agents based on NICE hypertension guidelines with clinical safety as the overriding priority
- Makes care pathway decisions with mandatory safety checks at each stage
- Escalates complex cases to GP with detailed clinical reasoning
- Maintains patient care timeline with fail-safe monitoring
- Ensures strict guideline compliance and patient safety

**Demo Workflow with Dummy Data:**
```
Patient: Michael Davies (ID: PT001) - *Simulated data only*
Initial BP: 165/95 mmHg (elevated)

1. Receives patient data for individuals due/overdue for BP monitoring per NICE guidelines
2. Analyses patient data with safety screening: Age 55, BMI 28, no diabetes, smoker
3. Safety check: Reviews for any contraindications or risk factors requiring immediate GP consultation
4. Initiates NICE pathway: Stage 1 hypertension protocol with safety monitoring
5. Coordinates with BP Measurement Agent for community monitoring
6. Schedules lifestyle intervention via Lifestyle Agent
7. Sets 4-week review milestone with mandatory safety checkpoint
8. Continuous monitoring: Any deviation from expected pathway triggers GP escalation
```

**Comprehensive Escalation Protocols:**
**Immediate GP Escalation (same day):**
- Severe hypertension (≥180/110 mmHg)
- Symptoms of end-organ damage (headaches, visual changes, chest pain, breathlessness)
- Acute cardiovascular events or symptoms
- Medication adverse reactions or contraindications
- Patient pregnancy (hypertension in pregnancy requires specialist management)
- Signs of secondary hypertension
- Patient unable to provide informed consent
- Multiple missed appointments raising safety concerns

**Urgent GP Escalation (within 48 hours):**
- No improvement after 4 weeks of optimal treatment
- Significant BP variability or treatment resistance
- Patient non-adherence to medication requiring clinical assessment
- Comorbidity developments (diabetes, kidney disease, cardiovascular disease)
- Patient reporting concerning symptoms
- Abnormal blood test results requiring interpretation

**Routine GP Escalation (within 1 week):**
- No improvement after 3 months of intervention
- Patient request for GP consultation
- Complex treatment decisions requiring clinical judgement
- Need for specialist referral consideration
- Annual medication review requirements

### 2. BP Measurement Agent

**Purpose:** Simulates BP checks via multiple community locations including Lifelight technology, pharmacy partnerships, GP practice waiting rooms, and other accessible venues

**Key Responsibilities:**
- Coordinate community-based BP monitoring
- Validate measurement quality
- Schedule regular monitoring intervals
- Interface with Lifelight app and pharmacy networks

**Demo Workflow with Dummy Data:**
```
Patient: Jennifer Roberts (ID: PT002)
Current medication: Amlodipine 5mg

Simulation Steps:
1. Receives monitoring request from Orchestrating Agent
2. Locates nearest BP monitoring location (GP practice waiting room, Boots pharmacy Mill Road - 0.3 miles, or community health hub)
3. Books appointment slot: Tuesday 2:00 PM
4. Simulates measurement: 145/88 mmHg (*dummy data for demonstration*)
5. Quality check: Measurement meets NHS standards
6. Reports back to Orchestrating Agent
7. Schedules next measurement per NICE guidelines: 4 weeks for stable treated hypertension
```

**Dummy Data Sources:**
- BP monitoring locations: 15 pharmacies, 8 GP practices with waiting room devices, 5 community health hubs within 5-mile radius
- Lifelight app integration: 89% measurement success rate
- Average measurement time: 3 minutes

### 3. Diagnosing Agent

**Purpose:** Simulates arrangement of 24-hour ambulatory BP monitoring and provides evidence-based recommendations requiring GP approval for all new hypertension diagnoses (Note: Patients with existing essential hypertension diagnosis can bypass this agent)

**Human-in-the-Loop Requirement:** No patient can receive a new diagnosis of essential hypertension without GP approval. The system provides evidence-based recommendations and evidence packs to the GP, but the final diagnostic decision and treatment initiation requires GP confirmation.

**Key Responsibilities:**
- Arrange ambulatory blood pressure monitoring (ABPM) through Boots pharmacies
- Analyse 24-hour BP patterns
- Compile evidence packages for GP review
- Provide structured diagnostic recommendations
- Await GP go/no-go approval before proceeding with treatment pathways

**Demo Workflow with Dummy Data:**
```
Patient: Preet Patel (ID: PT003) - *Simulated data only*
Clinic readings: 155/92, 158/95, 152/89 mmHg

Simulation Process:
1. Triggered by 3 elevated clinic readings
2. Arranges ABPM at Boots pharmacy (Mill Road branch)
3. Simulated 24h data:
   - Daytime average: 148/86 mmHg (*dummy data*)
   - Nighttime average: 135/78 mmHg (*dummy data*)
   - Nocturnal dipping: 9% (normal) (*simulated*)
4. Analysis: Evidence suggests stage 1 hypertension
5. Compiles evidence package with ABPM data, risk factors, and NICE guideline recommendations
6. Sends structured report to GP for diagnostic approval
7. Awaits GP confirmation before patient transitions to Category A management
8. If GP approves: Patient moves to treatment pathway
9. If GP declines: Returns to surveillance or requests additional investigations
```

**Simulated Equipment:**
- ABPM devices available at Boots: Spacelabs 90217, 90207 (*demonstration equipment*)
- Booking system integration: 72-hour typical wait time (*simulated data*)
- Data analysis algorithms: NICE-compliant thresholds

### 4. Lifestyle Agent

**Purpose:** Simulates referrals to services for sodium/alcohol reduction, exercise programmes, dietary modifications, smoking cessation, stress management, and sleep hygiene support

**Key Responsibilities:**
- Assess lifestyle risk factors through accessible, multi-modal questionnaires
- Coordinate referrals to culturally-appropriate lifestyle services
- Provide interventions in multiple languages and accessible formats
- Cross-reference with NHS London "Million Hearts and Minds" programme for evidence-based, culturally-sensitive interventions

**Accessibility Features:**
- **Multiple delivery methods (free NHS service):** Online forms, voice conversations with AI agents, telephone support, face-to-face consultations (reserved for digitally excluded patients only)
- **Language support:** Available in major community languages plus BSL interpretation services
- **Accessible formats:** EasyRead versions, large print, audio descriptions, screen reader compatibility
- **Cultural sensitivity:** Culturally-appropriate dietary advice, religious considerations, community-specific programmes
- Track intervention progress
- Provide educational resources

**Demo Workflow with Dummy Data:**
```
Patient: David Johnson (ID: PT004) - *Simulated data only*
Risk factors: High sodium diet, sedentary lifestyle, moderate alcohol use, smoking, poor sleep

Intervention Simulation:
1. Lifestyle assessment questionnaire completed via AI voice agent in patient's preferred language (English)
2. Identifies priorities: Diet (sodium reduction), Exercise, Alcohol, Smoking cessation, Stress management
3. Culturally-appropriate referrals made:
   - NHS Healthier You: Weight management programme with cultural dietary guidance
   - Local leisure centre: Women-only cardiac rehabilitation exercise class
   - Alcohol support: Culturally-sensitive NHS alcohol units calculator with community-specific guidance
   - NHS Stop Smoking Service: Bilingual counsellor appointment
   - Stress management: Community-based mindfulness programme respecting cultural practices
   - Sleep hygiene: NHS Better Health sleep advice with cultural sleep practices integration
4. Multi-format educational materials sent: DASH diet guide (EasyRead + audio), home BP monitoring video tutorial, culturally-adapted smoking cessation toolkit
5. 4-week follow-up scheduled with preferred communication method
6. Progress tracking: Weight loss 2kg, exercise 3x/week, alcohol reduction 30%, quit smoking day 18 (*dummy progress data*)
```

**Simulated Services:**
- NHS Healthier You programmes: 12 local providers with cultural dietary specialists (*demonstration data*)
- Exercise referral schemes: 8 participating gyms/centres with accessibility features and cultural considerations
- Dietitian services: 5-week waiting list, multilingual support available
- NHS Stop Smoking Services: 15 local advisors, 8 offering language support
- Stress management courses: 6 providers offering culturally-adapted MBSR programmes
- Sleep hygiene programmes: NHS Better Health digital platform with cultural adaptation features
- Digital health tools: NHS Food Scanner app (multilingual), Couch to 5K (accessible), Smoke Free app (EasyRead)
- **Cultural programmes:** NHS London "Million Hearts and Minds" affiliated community interventions

### 5. Shared Decision-Making Agent

**Purpose:** Simulates patient support in selecting antihypertensive medications based on preferences and side effects. Strong evidence in the scientific literature demonstrates that shared decision-making leads to better outcomes, particularly higher adherence to antihypertensive medications.

**Key Responsibilities:**
- Present treatment options through multiple accessible formats and media
- Explain benefits and risks using patient-preferred communication methods
- Consider patient preferences, cultural factors, and comorbidities  
- Support informed decision-making with comprehensive NHS service integration

**Multi-Media Accessibility Features:**
- **Video content:** Subtitled explanation videos in multiple languages
- **Podcast-style audio:** For patients preferring audio learning
- **AI chatbots:** Interactive Q&A sessions about medication options
- **Virtual avatars:** Culturally-representative healthcare advisors
- **Language support:** Full translation services and EasyRead formats
- **BSL interpretation:** Video consultations with BSL interpreters

**Demo Workflow with Dummy Data:**
```
Patient: Robert MacDonald (ID: PT005) - *Simulated data only*
Profile: 62 years old, active lifestyle, concerns about fatigue

NHS Decision-Making Simulation:
1. Presents 3 first-line NHS treatment options via patient's preferred format (interactive video):
   - ACE inhibitor (Ramipril): Good for active patients, dry cough risk
   - Calcium channel blocker (Amlodipine): Effective, may cause ankle swelling  
   - Thiazide diuretic (Indapamide): Cost-effective, increased urination
   
2. Patient priorities identified through AI conversation:
   - Maintain energy levels for cycling
   - Minimize impact on daily activities
   - Preference for NHS-recommended options

3. Multi-format educational materials provided:
   - Subtitled video explanations (5 minutes each, available in multiple languages e.g., Welsh/Urdu/Polish)
   - Audio podcast-style medication guides
   - Interactive AI chatbot Q&A session
   - Cultural avatar providing culturally-appropriate advice
   - EasyRead comparison charts

4. Patient choice made through accessible interface: ACE inhibitor (Ramipril 2.5mg)
5. NHS monitoring plan agreed: BP check in 4 weeks at preferred community location
```

**NHS Decision Support Tools:**
- Interactive NHS medication comparison portal (*simulated interface*)
- Side effect probability calculator aligned with NHS patient information
- Cultural preference questionnaire with community health considerations
- Educational videos featuring diverse NHS patients (*dummy testimonials*)
- Multilingual AI chatbots for detailed medication discussions

### 6. Titration Agent

**Purpose:** Simulates dose adjustment based on mock treatment response, strictly following NICE guidelines and British National Formulary protocols

**Key Responsibilities:**
- Monitor treatment response according to NICE-specified intervals
- Adjust medication doses per BNF guidance
- Add combination therapy following NICE algorithms
- Track side effects and efficacy using BNF-defined parameters

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

**Purpose:** Simulates U&E (Urea and Electrolytes) monitoring and other safety parameters, strictly adhering to NICE guidelines and British National Formulary monitoring requirements

**Key Responsibilities:**
- Schedule routine blood tests per NICE-specified intervals
- Monitor for medication-related complications as defined in BNF
- Alert to abnormal results using BNF thresholds
- Coordinate with GP for result review following NICE protocols

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

### 8. Medication Adherence Agent

**Purpose:** Proactive monitoring and support for medication compliance, using digital tools and behavioral interventions to optimize adherence to antihypertensive therapy

**Key Responsibilities:**
- Monitor medication adherence through digital pill reminders and patient reporting
- Identify early signs of non-compliance before clinical impact
- Provide personalized adherence support and behavioral interventions
- Coordinate with pharmacy for medication synchronization and support services

**Demo Workflow with Dummy Data:**
```
Patient: Helen Wright (ID: PT009)
Medication: Amlodipine 10mg daily, prescribed 6 weeks ago
Recent BP readings trending upward despite dose optimization

Adherence Monitoring Simulation:
1. Digital monitoring analysis:
   - NHS App medication tracker: 65% adherence (target >80%)
   - Missed doses: 10 out of last 30 days
   - Pattern identified: Weekend non-compliance

2. Proactive intervention triggered:
   - SMS reminder optimization: Weekend-specific alerts
   - Pharmacy consultation arranged: Dose timing discussion
   - Behavioral support: Habit-linking strategies

3. Patient engagement:
   - Educational call: Importance of consistent dosing
   - Side effect review: No significant issues reported
   - Barriers assessment: Forgetfulness during social activities

4. Support plan implemented:
   - Weekly pharmacy check-ins for 4 weeks
   - Weekend pill organizer provided
   - Family member notification system activated

5. Follow-up tracking:
   - 2-week reassessment: Adherence improved to 85%
   - BP response: 148/86 mmHg (improving trend)
   - Next review: Continue monitoring for 8 weeks
```

**Adherence Support Tools:**
- NHS App medication reminders with customizable timing
- Pharmacy partnership for medication synchronization
- Digital pill organizers with app connectivity
- Patient education videos on importance of adherence
- Family/carer notification systems with patient consent

### 9. Red Flag Agent

**Purpose:** Simulates red flag detection and escalation per NICE guidance and British National Formulary emergency protocols

**Key Responsibilities:**
- Continuous monitoring for warning signs per NICE criteria
- Immediate escalation protocols following BNF guidance
- Emergency pathway activation as specified in NICE guidelines
- Communication with emergency services per established protocols

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
   - GP assessment within 2 hours (if no GP confirmation within 15 minutes, escalate to out-of-hours service)
   - Hospital admission required per NICE CG127 if: BP ≥180/110 with papilloedema, life-threatening symptoms (chest pain, dyspnoea, neurological features), or suspected acute target organ damage
   - Same-day specialist assessment if BP ≥180/110 without life-threatening features but with cardiovascular complications
   - Antihypertensive therapy review per BNF protocols
   - 24-hour follow-up mandatory (if patient unreachable after 3 attempts over 6 hours, trigger welfare check via practice nurse or emergency contact)

4. Documentation: Incident logged for quality improvement
```

**Red Flag Triggers:**
- BP ≥180/110 mmHg with symptoms
- Signs of end-organ damage
- Severe medication non-compliance >14 days (flagged by Medication Adherence Agent)
- Patient-reported chest pain, shortness of breath
- Pregnancy with elevated BP

## User Journey Examples

### Journey 1: Category A - Known Hypertension Patient Starting System Management
```
Patient: Jennifer Lee, 45, diagnosed hypertension 6 weeks ago, GP referral for system management

Day 1: 
- Orchestrating Agent receives referral with confirmed diagnosis
- Current medication: Ramipril 2.5mg (newly started)
- Treatment Management Agent activated (bypasses diagnostic pathway)
- Medication Adherence Agent: Digital reminder system activated

Day 3:
- BP measurement scheduled: 152/88 mmHg (not at target)
- Monitoring Agent: U&E check scheduled
- Lifestyle Agent: Additional interventions assessed

Day 7:
- Shared Decision-Making consultation: Discuss dose optimization
- Patient agrees to titration approach
- Educational materials on BP self-monitoring provided
- Medication Adherence Agent: Baseline adherence 78% identified

Day 14:
- Titration Agent: Ramipril increased to 5mg
- Monitoring plan: 4-week review, U&E in 2 weeks
- Target: <140/90 mmHg
- Medication Adherence Agent: Adherence support reinforced for new dose

Week 6:
- BP check: 138/82 mmHg (target achieved)
- Monitoring schedule: Monthly reviews
- Medication Adherence Agent: Sustained 95% adherence achieved
- Transition to maintenance phase
```

### Journey 2: Category B - Normotensive Surveillance Patient
```
Patient: Mark Johnson, 45, annual BP check due, no previous hypertension

Day 1:
- Practice recall system triggers BP monitoring
- Orchestrating Agent: Routine surveillance pathway
- Patient: Family history of hypertension, BMI 27

Day 3:
- BP Measurement Agent: Pharmacy screening
- Reading: 128/78 mmHg (normal, high-normal)
- Lifestyle Agent: Preventive assessment initiated

Day 7:
- Lifestyle recommendations: Weight management, exercise programme
- Educational materials: CVD prevention, healthy eating
- No medication indicated

Day 14:
- Follow-up questionnaire: Lifestyle changes implemented
- Next BP check: 12 months (annual recall)
- System status: Surveillance maintenance

*Escalation scenario if elevated:*
If BP reading ≥140/90: Automatic transition to Category C diagnostic pathway
```

### Journey 3: Category C - Newly Detected Elevated BP Patient
```
Patient: Sarah Williams, 38, elevated reading at community screening, no previous diagnosis

Day 1:
- Community pharmacy screening: 158/92 mmHg
- Orchestrating Agent: Diagnostic pathway activated
- Patient notified via NHS App

Day 3:
- BP Measurement Agent: Repeat measurement at GP practice
- Reading: 162/94 mmHg (confirms elevation)
- Diagnosing Agent: ABPM arrangement triggered

Day 7:
- ABPM completed at local hospital
- 24-hour average: 148/88 mmHg (confirms stage 1 hypertension)
- Lifestyle assessment initiated

Day 14:
- Diagnosis confirmed: Essential hypertension
- Shared Decision-Making consultation scheduled
- Patient education: Understanding hypertension

Day 21:
- Medication decision: Amlodipine 5mg selected
- **Transition to Category A:** Treatment management pathway
- Monitoring schedule: 4-week review established

Week 8:
- Now managed as Category A patient
- BP target achieved: 135/82 mmHg
- Regular monitoring protocol active
```

### Journey 4: Red Flag Escalation (All Categories)
```
Patient: Alan Murphy, 72, Category A patient, established hypertension on treatment

Day 1:
- Routine BP check: 188/112 mmHg
- Patient reports headache, nausea
- Red Flag Agent immediately activated

Day 1 (within 30 minutes):
- GP surgery contacted automatically
- Urgent appointment arranged
- Patient advised to avoid driving, rest immediately

Day 1 (2 hours later):
- GP assessment completed
- Hospital referral made: Hypertensive emergency
- Antihypertensive therapy intensified

Day 2:
- Hospital discharge with new medication plan
- Follow-up BP: 165/95 mmHg (improved)
- Enhanced monitoring protocol: Daily for 1 week

Day 7:
- BP stabilized: 142/88 mmHg
- Return to routine Category A management
- Medication titration plan adjusted
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

### Patient Profiles by Category (Dummy Data)

**Category A - Known Hypertension Patients (25 profiles)**
- Age range: 45-75 years
- Established hypertension diagnosis
- Various treatment stages: newly diagnosed (8), stable on treatment (12), requiring optimization (5)
- Medication status: Treatment-naive (8), monotherapy (10), combination therapy (7)

**Category B - Normotensive Surveillance Patients (15 profiles)**  
- Age range: 35-65 years
- Normal BP readings requiring monitoring
- Risk factors: Family history (8), previous borderline readings (4), cardiovascular risk factors (3)
- Monitoring frequency: Annual (12), 6-monthly (3 high-risk)

**Category C - Newly Detected Elevated BP Patients (10 profiles)**
- Age range: 35-70 years  
- Recent elevated readings at community screening
- Various presentation: Pharmacy screening (4), GP opportunistic (3), Occupational health (2), Self-referral (1)
- Diagnostic stage: Awaiting ABPM (4), ABPM completed (3), Diagnosis confirmed (3)

### Clinical Data by Category
**Category A Clinical Data:**
- BP readings: 135-180/85-110 mmHg (treatment response variation)
- Laboratory results: ACE inhibitor monitoring profiles, diuretic effects
- Medication responses: Based on real-world effectiveness data (60% achieve target with optimization)

**Category B Clinical Data:**
- BP readings: 110-139/70-89 mmHg (normal to high-normal range)
- Annual screening patterns: 90% within normal range, 10% develop elevated readings
- Lifestyle factors: Mixed cardiovascular risk profiles

**Category C Clinical Data:**
- Initial BP readings: 140-175/90-105 mmHg (stage 1-2 hypertension range)  
- ABPM data: Realistic 24-hour patterns with 15% white coat effect
- Diagnostic outcomes: 85% confirm hypertension, 15% white coat/masked hypertension

### Service Provider Data
- 15 pharmacy locations with realistic wait times
- 5 hospital services for ABPM
- 10 lifestyle intervention providers
- Typical NHS waiting times applied

## Success Metrics by Patient Category (Simulated)

### Category A - Known Hypertension Patients
**Clinical Outcomes:**
- 78% achieve target BP <140/90 within 12 weeks of system management
- 92% medication adherence rate
- 12% require treatment intensification
- 2% emergency escalations

**Operational Metrics:**
- Average time to treatment optimization: 6 weeks
- GP escalation rate: 18% of cases (complex patients)
- Patient satisfaction: 4.3/5 (treatment support)

### Category B - Normotensive Surveillance Patients  
**Clinical Outcomes:**
- 88% maintain normal BP at annual review
- 12% develop elevated readings requiring diagnostic pathway
- 95% attend routine monitoring appointments
- <1% emergency presentations

**Operational Metrics:**
- Surveillance compliance: 94% (annual recalls)
- Lifestyle intervention uptake: 65%
- Patient satisfaction: 4.1/5 (preventive care)

### Category C - Newly Detected Elevated BP Patients
**Clinical Outcomes:**
- 85% receive confirmed hypertension diagnosis within 6 weeks
- 15% diagnosed with white coat/masked hypertension
- 92% successfully transition to Category A management
- 89% attend ABPM appointments

**Operational Metrics:**
- Time to diagnosis: Average 4.2 weeks (NICE compliant)
- ABPM completion rate: 94%
- Patient satisfaction: 4.0/5 (diagnostic journey)

### Overall System Metrics
- Cross-category patient safety: 99.2% appropriate escalations
- System uptime: 99.5%
- Inter-agent communication success: 99.8%
- NHS App integration satisfaction: 4.2/5

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

## User Experience

### Patient Experience Within the App

**Primary Interface: NHS App Integration**
The patient experience centres around seamless integration within the existing NHS App, providing a familiar and trusted environment for BP management.

**Patient Dashboard:**
- **BP Trends**: Visual graphs showing BP readings over time with traffic light colour coding
- **Next Actions**: Clear, personalised recommendations (e.g., "Book pharmacy BP check by Friday")
- **Medication Reminders**: Intelligent notifications aligned with prescription schedules
- **Progress Tracking**: Lifestyle goals and achievements with encouraging feedback

**Patient Journey Features:**
- **Onboarding**: Guided setup with explanation of system benefits and privacy protections
- **BP Measurement Booking**: One-tap booking at nearby pharmacies, GP practices, or community hubs
- **Results Notification**: Immediate feedback on readings with explanations in plain English
- **Educational Content**: Personalised information about hypertension, lifestyle changes, and medications
- **Emergency Support**: Prominent "Get Help Now" button for urgent concerns

**Accessibility Features:**
- Large text options for elderly users
- Voice readback of key information
- Multi-language support for diverse communities
- Screen reader compatibility

### Healthcare Professional Administration Interface

**GP Practice Analytics Dashboard:**
This comprehensive dashboard provides practice-wide insights into hypertension management performance, with particular focus on addressing health inequalities and improving care for marginalised groups.

**Practice-Wide NICE Guidelines Adherence:**
- **Overall Compliance Score**: Real-time percentage of practice achieving NICE CG127 targets (baseline: 68%, target: 85%)
- **Guideline Metrics Dashboard**:
  - BP target achievement (<140/90): Overall practice rate with trend analysis
  - Medication titration adherence: Percentage following NICE algorithms
  - Monitoring interval compliance: Patients receiving timely follow-ups
  - ABPM utilisation: Diagnostic pathway adherence rates
  - Lifestyle intervention uptake: Referral completion rates

**Health Inequality Monitoring:**
- **Marginalised Groups Performance Tracking**:
  - **Socioeconomic deprivation** (IMD quintiles): BP control rates by deprivation level
  - **Ethnicity-based outcomes**: Comparative adherence and BP control across ethnic groups
  - **Language barriers**: Outcomes for patients requiring interpretation services
  - **Digital exclusion**: Performance comparison between app users vs non-users
  - **Age-related disparities**: Outcomes for elderly vs working-age populations
  - **Geographic access**: Rural vs urban patient management effectiveness

**Trend Analysis with Inequality Focus:**
- 12-month rolling trends showing whether gaps between marginalised and general populations are narrowing
- Heat maps identifying patient cohorts requiring targeted intervention
- Predictive analytics highlighting patients at risk of disengagement

**Individual Patient Drill-Down:**
- **Patient List Management**: Sortable views by risk level, deprivation score, ethnicity, language needs
- **Clinical Summary**: Full BP history, medication timeline, and comorbidity overview  
- **Care Pathway Tracking**: Progress through NICE protocols with deviation alerts
- **Social Determinants View**: Housing, employment, and social factors affecting health outcomes
- **Communication Preferences**: Preferred languages, accessibility needs, contact methods

**EHR Integration Requirements:**
- **EMIS Web Integration**: Real-time synchronisation of BP readings, medications, and clinical notes
- **TPP SystmOne Compatibility**: Seamless data exchange with practice clinical systems
- **SNOMED CT Coding**: Standardised clinical terminology for accurate data capture
- **QOF Reporting**: Automated Quality and Outcomes Framework indicator monitoring
- **Clinical Decision Support**: AI recommendations integrated into existing clinical workflows
- **Audit Trail**: Complete clinical governance logging for CQC compliance

**Practice Performance Metrics:**
- **Workload Reduction Indicators**: 
  - Reduction in routine hypertension appointments
  - Decreased emergency hypertension presentations
  - Automated administrative tasks completion
- **Clinical Safety Metrics**:
  - Zero-harm incidents related to AI system recommendations
  - Escalation response times to urgent alerts
  - Patient satisfaction with AI-supported care
- **Population Health Outcomes**:
  - Practice-wide BP control improvement
  - Cardiovascular event prevention metrics
  - Medication adherence improvements by demographic

**Practice Manager Interface:**
- **System Performance**: Metrics on patient engagement and outcome improvements
- **Resource Planning**: Prediction of appointment demands and pharmacy referrals
- **Staff Training**: Modules for understanding AI agent recommendations

**Pharmacist Portal:**
- **BP Measurement Queue**: Appointment scheduling and patient check-in
- **Clinical Alerts**: Notifications for patients with concerning readings
- **Lifestyle Referrals**: Interface for connecting patients to local services
- **Communication Hub**: Secure messaging with GP practices for complex cases

**System Administrator Console:**
- **Agent Monitoring**: Real-time status of all AI agents and their performance
- **Data Quality**: Validation checks and error reporting across the system
- **Safety Protocols**: Fail-safe monitoring and escalation pathway verification
- **User Support**: Help desk integration for technical issues

## Conclusion

This MVP demonstrates a comprehensive multi-agentic approach to hypertension management that could significantly improve patient outcomes while reducing GP workload. The demo version showcases the potential for AI-driven healthcare coordination while maintaining clinical safety through appropriate escalation protocols.

The simulated workflows and dummy data provide a realistic foundation for stakeholder evaluation and future development planning, focusing on the core value proposition without the complexity of full system integration.

---

*This document represents a demo version using simulated data and workflows. No real patient data or live clinical systems are involved in this demonstration.*