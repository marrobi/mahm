# My BP - Technical Architecture

**⚠️ SIMULATION ONLY - NOT FOR CLINICAL USE ⚠️**

## High-Level Overview

The My BP hypertension management system uses **Azure AI Foundry Connected Agents** to coordinate 9 specialized AI agents for comprehensive healthcare workflows with dummy patient data via Azure API for FHIR R4.

## Core Architecture Components

### Agent Network
- **Main Orchestrating Agent** - Central coordination and clinical safety
- **Specialized Healthcare Agents** (8) - BP monitoring, diagnosis, lifestyle, medication management, emergency detection
- **Natural language routing** via Azure AI Foundry Connected Agents service

### Azure Infrastructure
- **Azure AI Foundry workspace** with connected agents configuration
- **Azure API for FHIR R4** with comprehensive dummy healthcare data
- **Azure Cosmos DB** for permanent conversation storage and clinical history
- **My BP API Gateway** for client interface coordination
- **Azure Monitor + Application Insights** for clinical safety monitoring

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│              Client Interfaces                              │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────────┐ │
│  │  NHS App    │ │   Web UI    │ │  Clinician Dashboard    │ │
│  │  Interface  │ │   Portal    │ │       & Mobile App      │ │
│  └─────────────┘ └─────────────┘ └─────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────┐
│                   My BP API Gateway                         │
│           (Intermediary Layer - Not Direct FHIR)           │
└─────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────┐
│                Azure AI Foundry Connected Agents           │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │            Main Orchestrating Agent                     │ │
│  │         (Natural Language Routing Hub)                  │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                │                              │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              Specialized Agent Network                  │ │
│  │  BP • Diagnosis • Lifestyle • Decision • Titration     │ │
│  │        • Monitoring • Adherence • Red Flag             │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
          │                    │                    │
┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐
│  Azure Cosmos DB │ │ Azure API for    │ │ Azure Monitor +  │
│                  │ │      FHIR        │ │  App Insights    │
│ • Conversation   │ │                  │ │                  │
│   History        │ │ • Dummy Patient  │ │ • Safety Alerts  │
│ • Agent          │ │   Data (A,B,C)   │ │ • Audit Trails   │
│   Responses      │ │ • Clinical       │ │ • Real-time      │
│ • Permanent      │ │   Resources      │ │   Monitoring     │
│   Storage        │ │                  │ │                  │
└──────────────────┘ └──────────────────┘ └──────────────────┘
```

## Data Flow & Integration

### Client-to-Agent Communication
1. **Client Interfaces** (NHS App, Web Portal, Mobile App, Clinician Dashboard) → 
2. **My BP API Gateway** (authentication, validation, routing) →
3. **Azure AI Foundry Connected Agents** (natural language processing) →
4. **Specialized Agents** (clinical decision-making) →
5. **Azure FHIR + Cosmos DB** (data storage & retrieval) →
6. **Formatted Response** → Client Interface

### Key Integration Points
- **NHS App Integration**: Blood pressure recording, medication tracking, care plan dashboard
- **API Gateway Layer**: Intermediary between clients and agents (not direct FHIR access)
- **Conversation Storage**: Permanent storage in both Cosmos DB and FHIR Communication resources
- **Emergency Escalation**: Real-time red flag detection with <30 second response times

## User Interface Architecture

### NHS App Integration
- **Blood Pressure Recording Screen** with validation
- **Medication Tracker** with adherence logging  
- **Care Plan Dashboard** with personalized recommendations
- **Community Pharmacy Finder** for BP monitoring locations

### Clinician Dashboard
- **Patient Triage View** with AI-generated risk priorities
- **Diagnostic Decision Support** with ABPM recommendations
- **Medication Management** with titration guidance
- **Population Health Analytics** for community insights

### Mobile Application
- **Smart BP Logging** with OCR capabilities
- **Medication Reminders** with intelligent notifications
- **Lifestyle Goal Tracking** with cultural adaptations
- **Emergency Alert System** for critical readings

## Healthcare Agent Orchestration

### Enhanced Clinical Safety
- **Multi-agent validation** for critical clinical decisions
- **Clinical workflow state management** across patient care pathways  
- **"Back to you" yield control** patterns for proper agent handoffs
- **Safety gate enforcement** with mandatory clinical checkpoints
- **Circuit breaker patterns** for agent failure scenarios

### Emergency Response Coordination
- **Real-time monitoring** across all clinical data sources
- **Multi-tier escalation** (Immediate/Urgent/Routine)
- **Coordinated emergency response** with external systems integration
- **Clinical context preservation** during emergency scenarios

## MVP Implementation Phases

### Phase 1: Foundation + Basic Agent Demo (Weeks 1-4)
**Deliverables:**
- Deploy Azure AI Foundry workspace with Connected Agents
- Configure FHIR server with dummy patient data (Categories A, B, C)
- Implement Main Orchestrating Agent with natural language routing
- Set up Cosmos DB for conversation storage
- Deploy basic API Gateway with authentication

**Demo:** Basic conversational AI agent that can answer hypertension questions and route to appropriate clinical responses using dummy patient data. Simple web interface showing agent conversations.

### Phase 2: Core Clinical Agents Demo (Weeks 5-8)
**Deliverables:**
- Deploy Red Flag Agent with emergency detection (<30s response)
- Configure BP Measurement Agent for community monitoring
- Implement Diagnosing Agent with ABPM coordination
- Establish clinical safety monitoring and multi-agent communication
- Deploy emergency alert infrastructure

**Demo:** Multi-agent clinical scenarios including emergency detection (red flag alerts), BP monitoring recommendations, and basic diagnostic workflows. Show agent-to-agent handoffs and clinical safety checks.

### Phase 3: Complete Agent Network Demo (Weeks 9-12)
**Deliverables:**
- Implement Titration Agent with NICE compliance
- Configure Monitoring Agent for lab coordination
- Add Lifestyle Agent with cultural adaptations
- Deploy Shared Decision-Making Agent
- Implement comprehensive multi-agent clinical consultations

**Demo:** Full 9-agent network handling complex clinical scenarios including medication titration, lifestyle recommendations with cultural adaptations, and sophisticated multi-agent consultations for complex hypertension cases.

### Phase 4: User Interface Demo (Weeks 13-16)
**Deliverables:**
- Develop NHS App integration module
- Build clinician dashboard with patient triage
- Create mobile application with smart BP logging features
- Implement emergency alert systems in UIs
- Deploy user authentication and authorization

**Demo:** Complete end-to-end user journeys through NHS App integration, mobile app BP logging, and clinician dashboard patient management. Show real-time emergency alerts and patient triage workflows.

### Phase 5: Advanced Features Demo (Weeks 17-20)
**Deliverables:**
- Implement Medication Adherence Agent with intelligent reminders
- Deploy advanced healthcare orchestration patterns
- Add population health analytics dashboard
- Implement comprehensive audit trails and compliance reporting
- Deploy advanced agent coordination patterns

**Demo:** Advanced population health insights, medication adherence tracking, sophisticated orchestration patterns for complex clinical workflows, and comprehensive audit/compliance reporting capabilities.

### Phase 6: Production-Ready System Demo (Weeks 21-24)
**Deliverables:**
- Comprehensive safety testing with dummy data scenarios
- Performance optimization and scalability validation
- Emergency response testing and validation
- Clinical safety compliance verification
- Final system integration and optimization

**Demo:** Production-ready system handling high-volume scenarios, demonstrating scalability, performance metrics, comprehensive safety validation results, and full clinical workflow simulation ready for pilot deployment.

---

*This architecture provides a comprehensive technical foundation for the My BP multi-agentic AI hypertension management system using Azure AI Foundry Connected Agents with complete dummy data simulation for healthcare workflow demonstration.*