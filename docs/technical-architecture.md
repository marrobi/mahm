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

### Phase 1: Core Infrastructure (Weeks 1-4)
- Deploy Azure AI Foundry workspace with Connected Agents
- Configure FHIR server with dummy patient data (Categories A, B, C)
- Implement basic API Gateway with authentication
- Set up Cosmos DB for conversation storage
- Deploy monitoring and logging infrastructure

### Phase 2: Essential Agents (Weeks 5-8) 
- Implement Main Orchestrating Agent with natural language routing
- Deploy Red Flag Agent with emergency detection (<30s response)
- Configure BP Measurement Agent for community monitoring
- Implement basic agent-to-agent communication patterns
- Establish clinical safety monitoring

### Phase 3: Clinical Workflow Agents (Weeks 9-12)
- Deploy Diagnosing Agent with ABPM coordination
- Implement Titration Agent with NICE compliance
- Configure Monitoring Agent for lab coordination
- Add Lifestyle Agent with cultural adaptations
- Implement multi-agent clinical consultations

### Phase 4: User Interfaces (Weeks 13-16)
- Develop NHS App integration module
- Build clinician dashboard with patient triage
- Create mobile application with smart features
- Implement emergency alert systems
- Deploy user authentication and authorization

### Phase 5: Advanced Features (Weeks 17-20)
- Add Shared Decision-Making Agent
- Implement Medication Adherence Agent
- Deploy advanced healthcare orchestration patterns
- Add population health analytics
- Implement comprehensive audit trails

### Phase 6: Testing & Validation (Weeks 21-24)
- Comprehensive safety testing with dummy data scenarios
- Multi-agent workflow validation
- Emergency response testing
- Performance optimization
- Clinical safety compliance verification

---

*This architecture provides a comprehensive technical foundation for the My BP multi-agentic AI hypertension management system using Azure AI Foundry Connected Agents with complete dummy data simulation for healthcare workflow demonstration.*