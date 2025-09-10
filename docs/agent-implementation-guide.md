# My BP Agent Implementation Guide

**⚠️ SIMULATION ONLY - NOT FOR CLINICAL USE ⚠️**

*This guide provides detailed implementation specifications for each of the 9 agents in the My BP multi-agentic AI hypertension management system using dummy data on Azure AI Foundry.*

## Implementation Overview

### Development Framework

Each agent follows a standardized implementation pattern:

- **Container-based deployment** using Python FastAPI
- **Azure AI Foundry integration** for model hosting and management
- **FHIR R4 compliance** for all data operations
- **Service Bus messaging** for inter-agent communication
- **Comprehensive logging** and monitoring integration
- **Circuit breaker patterns** for resilience
- **Dummy data validation** at all entry points

### Base Agent Class

```python
from abc import ABC, abstractmethod
from typing import Dict, Any, List, Optional
from pydantic import BaseModel
from azure.servicebus import ServiceBusClient, ServiceBusMessage
from azure.identity import DefaultAzureCredential
import asyncio
import logging

class AgentMessage(BaseModel):
    message_id: str
    correlation_id: str
    source_agent: str
    target_agent: str
    message_type: str  # REQUEST, RESPONSE, EVENT, ALERT
    priority: str  # LOW, NORMAL, HIGH, CRITICAL
    payload: Dict[str, Any]
    timestamp: str
    metadata: Dict[str, Any]

class AgentResponse(BaseModel):
    response_id: str
    correlation_id: str
    status: str  # SUCCESS, ERROR, PARTIAL
    result: Optional[Dict[str, Any]] = None
    error: Optional[Dict[str, Any]] = None
    recommendations: List[str] = []
    next_actions: List[Dict[str, Any]] = []

class BaseAgent(ABC):
    def __init__(self, agent_name: str, config: Dict[str, Any]):
        self.agent_name = agent_name
        self.config = config
        self.logger = logging.getLogger(f"agent.{agent_name}")
        self.fhir_client = self._initialize_fhir_client()
        self.service_bus_client = self._initialize_service_bus()
        self.telemetry = self._initialize_telemetry()
        
    @abstractmethod
    async def process_message(self, message: AgentMessage) -> AgentResponse:
        """Process incoming message and return response"""
        pass
    
    @abstractmethod
    async def health_check(self) -> Dict[str, Any]:
        """Return agent health status"""
        pass
    
    def validate_dummy_data(self, data: Dict[str, Any]) -> bool:
        """Ensure all data operations use dummy data only"""
        # Check for dummy data markers
        if isinstance(data, dict):
            patient_id = data.get('patient_id', data.get('patientId', ''))
            if patient_id and not patient_id.startswith('DUMMY-'):
                raise ValueError("Only dummy patient data is allowed in demo environment")
        return True
    
    async def send_message(self, target_agent: str, message_type: str, payload: Dict[str, Any]) -> None:
        """Send message to another agent via Service Bus"""
        message = AgentMessage(
            message_id=str(uuid.uuid4()),
            correlation_id=str(uuid.uuid4()),
            source_agent=self.agent_name,
            target_agent=target_agent,
            message_type=message_type,
            priority="NORMAL",
            payload=payload,
            timestamp=datetime.utcnow().isoformat(),
            metadata={"is_dummy_data": True}
        )
        
        await self._send_to_service_bus(message)
        
    def _initialize_fhir_client(self):
        # Initialize FHIR client with Azure API for FHIR
        pass
    
    def _initialize_service_bus(self):
        # Initialize Service Bus client
        pass
    
    def _initialize_telemetry(self):
        # Initialize Application Insights telemetry
        pass
```

## Agent-Specific Implementations

### 1. Orchestrating Agent

**Purpose**: Central coordination agent prioritizing clinical safety above all else

```python
from typing import Dict, Any, List
from datetime import datetime, timedelta
import asyncio

class OrchestrationAgent(BaseAgent):
    def __init__(self, config: Dict[str, Any]):
        super().__init__("orchestrating-agent", config)
        self.care_pathways = {}
        self.escalation_timeouts = {
            "critical": timedelta(minutes=15),
            "urgent": timedelta(hours=2),
            "routine": timedelta(hours=24)
        }
    
    async def process_message(self, message: AgentMessage) -> AgentResponse:
        """Central orchestration logic with safety-first approach"""
        self.validate_dummy_data(message.payload)
        
        try:
            action = message.payload.get('action')
            patient_id = message.payload.get('patient_id')
            
            # Safety check: Validate patient exists and is dummy data
            patient = await self._get_patient(patient_id)
            if not self._is_dummy_patient(patient):
                raise ValueError("Real patient data not allowed in demo environment")
            
            # Route to appropriate handler
            if action == "initiate_care_pathway":
                return await self._initiate_care_pathway(message)
            elif action == "update_care_status":
                return await self._update_care_status(message)
            elif action == "escalate_to_gp":
                return await self._escalate_to_gp(message)
            elif action == "safety_check":
                return await self._perform_safety_check(message)
            else:
                return AgentResponse(
                    response_id=str(uuid.uuid4()),
                    correlation_id=message.correlation_id,
                    status="ERROR",
                    error={"code": "UNKNOWN_ACTION", "message": f"Unknown action: {action}"}
                )
                
        except Exception as e:
            self.logger.error(f"Error processing message: {str(e)}")
            return AgentResponse(
                response_id=str(uuid.uuid4()),
                correlation_id=message.correlation_id,
                status="ERROR",
                error={"code": "PROCESSING_ERROR", "message": str(e)}
            )
    
    async def _initiate_care_pathway(self, message: AgentMessage) -> AgentResponse:
        """Initiate care pathway based on patient category and clinical data"""
        patient_id = message.payload['patient_id']
        
        # Get patient data from FHIR
        patient = await self._get_patient(patient_id)
        category = self._get_patient_category(patient)
        
        # Safety check: Red flag screening first
        red_flag_check = await self._check_red_flags(patient_id)
        if red_flag_check.get('red_flags_detected'):
            # Immediate escalation for safety
            await self._escalate_to_gp(message, urgency="immediate")
            return AgentResponse(
                response_id=str(uuid.uuid4()),
                correlation_id=message.correlation_id,
                status="SUCCESS",
                result={"pathway": "emergency_escalation"},
                recommendations=["Immediate GP consultation required"]
            )
        
        # Determine pathway based on category
        if category == "A":  # Known hypertension
            pathway = await self._initiate_category_a_pathway(patient_id)
        elif category == "B":  # Surveillance
            pathway = await self._initiate_category_b_pathway(patient_id)
        elif category == "C":  # Newly detected
            pathway = await self._initiate_category_c_pathway(patient_id)
        else:
            raise ValueError(f"Unknown patient category: {category}")
        
        # Store pathway in care plan
        await self._create_care_plan(patient_id, pathway)
        
        # Schedule next steps with safety monitoring
        await self._schedule_pathway_actions(patient_id, pathway)
        
        return AgentResponse(
            response_id=str(uuid.uuid4()),
            correlation_id=message.correlation_id,
            status="SUCCESS",
            result={"pathway": pathway, "patient_category": category},
            next_actions=pathway.get('next_actions', [])
        )
    
    async def health_check(self) -> Dict[str, Any]:
        """Orchestrating agent health check"""
        health_status = {
            "status": "healthy",
            "timestamp": datetime.utcnow().isoformat(),
            "agent": self.agent_name,
            "dependencies": {}
        }
        
        # Check FHIR connectivity
        try:
            await self.fhir_client.search('Patient', {'_count': 1})
            health_status["dependencies"]["fhir_service"] = "available"
        except Exception:
            health_status["dependencies"]["fhir_service"] = "unavailable"
            health_status["status"] = "degraded"
        
        # Check Service Bus connectivity
        try:
            # Test service bus connection
            health_status["dependencies"]["service_bus"] = "connected"
        except Exception:
            health_status["dependencies"]["service_bus"] = "disconnected"
            health_status["status"] = "unhealthy"
        
        return health_status
```

### 2. BP Measurement Agent

**Purpose**: Coordinate community-based BP monitoring with dummy data

```python
class BPMeasurementAgent(BaseAgent):
    def __init__(self, config: Dict[str, Any]):
        super().__init__("bp-measurement-agent", config)
        self.measurement_locations = self._load_dummy_locations()
    
    async def process_message(self, message: AgentMessage) -> AgentResponse:
        """Handle BP measurement coordination"""
        self.validate_dummy_data(message.payload)
        
        action = message.payload.get('action')
        
        if action == "schedule_measurement":
            return await self._schedule_measurement(message)
        elif action == "record_measurement":
            return await self._record_measurement(message)
        elif action == "find_locations":
            return await self._find_measurement_locations(message)
        else:
            return self._error_response(message.correlation_id, "UNKNOWN_ACTION")
    
    async def _record_measurement(self, message: AgentMessage) -> AgentResponse:
        """Record new BP measurement in FHIR"""
        measurement_data = message.payload['measurement']
        patient_id = message.payload['patient_id']
        
        # Validate measurement data
        if not self._validate_bp_measurement(measurement_data):
            return self._error_response(message.correlation_id, "INVALID_MEASUREMENT")
        
        # Create FHIR Observation
        observation = {
            "resourceType": "Observation",
            "status": "final",
            "category": [{
                "coding": [{
                    "system": "http://terminology.hl7.org/CodeSystem/observation-category",
                    "code": "vital-signs"
                }]
            }],
            "code": {
                "coding": [{
                    "system": "http://loinc.org",
                    "code": "85354-9",
                    "display": "Blood pressure panel"
                }]
            },
            "subject": {"reference": f"Patient/{patient_id}"},
            "effectiveDateTime": measurement_data['timestamp'],
            "component": [
                {
                    "code": {"coding": [{"system": "http://loinc.org", "code": "8480-6"}]},
                    "valueQuantity": {
                        "value": measurement_data['systolic'],
                        "unit": "mmHg",
                        "system": "http://unitsofmeasure.org"
                    }
                },
                {
                    "code": {"coding": [{"system": "http://loinc.org", "code": "8462-4"}]},
                    "valueQuantity": {
                        "value": measurement_data['diastolic'],
                        "unit": "mmHg",
                        "system": "http://unitsofmeasure.org"
                    }
                }
            ],
            "extension": [{
                "url": "http://mybp.nhs.uk/fhir/extension/dummy-data-marker",
                "valueBoolean": True
            }]
        }
        
        # Store in FHIR
        created_observation = await self.fhir_client.create(observation)
        
        # Notify orchestrating agent of new measurement
        await self.send_message(
            target_agent="orchestrating-agent",
            message_type="EVENT",
            payload={
                "event_type": "bp_measurement_recorded",
                "patient_id": patient_id,
                "measurement": measurement_data,
                "observation_id": created_observation['id']
            }
        )
        
        return AgentResponse(
            response_id=str(uuid.uuid4()),
            correlation_id=message.correlation_id,
            status="SUCCESS",
            result={
                "observation_id": created_observation['id'],
                "measurement_recorded": True,
                "next_measurement_due": self._calculate_next_measurement_date(patient_id)
            }
        )
    
    def _load_dummy_locations(self) -> List[Dict[str, Any]]:
        """Load dummy measurement locations for simulation"""
        return [
            {
                "id": "loc-001",
                "name": "Boots Pharmacy - Mill Road",
                "type": "pharmacy",
                "address": {
                    "line": ["123 Mill Road"],
                    "city": "Cambridge",
                    "postcode": "CB1 2AB"
                },
                "capabilities": {
                    "abpm_available": True,
                    "wheelchair_accessible": True,
                    "languages_supported": ["English", "Urdu", "Polish"]
                }
            }
        ]
    
    async def health_check(self) -> Dict[str, Any]:
        """BP Measurement agent health check"""
        return {
            "status": "healthy",
            "timestamp": datetime.utcnow().isoformat(),
            "agent": self.agent_name,
            "capabilities": {
                "measurement_scheduling": True,
                "location_discovery": True,
                "fhir_integration": True
            },
            "available_locations": len(self.measurement_locations)
        }
```

### 3. Red Flag Agent

**Purpose**: Emergency detection and escalation with dummy data scenarios

```python
class RedFlagAgent(BaseAgent):
    def __init__(self, config: Dict[str, Any]):
        super().__init__("red-flag-agent", config)
        self.alert_thresholds = {
            "critical_bp": {"systolic": 180, "diastolic": 110},
            "severe_bp": {"systolic": 200, "diastolic": 120},
            "symptom_flags": [
                "chest_pain", "shortness_of_breath", "severe_headache",
                "visual_disturbance", "confusion", "seizure"
            ]
        }
        self.escalation_protocols = self._load_escalation_protocols()
    
    async def process_message(self, message: AgentMessage) -> AgentResponse:
        """Process clinical data for red flag detection"""
        self.validate_dummy_data(message.payload)
        
        action = message.payload.get('action')
        
        if action == "evaluate_red_flags":
            return await self._evaluate_red_flags(message)
        elif action == "escalate_alert":
            return await self._escalate_alert(message)
        elif action == "monitor_continuous":
            return await self._setup_continuous_monitoring(message)
        else:
            return self._error_response(message.correlation_id, "UNKNOWN_ACTION")
    
    async def _evaluate_red_flags(self, message: AgentMessage) -> AgentResponse:
        """Comprehensive red flag evaluation"""
        patient_id = message.payload['patient_id']
        clinical_data = message.payload.get('clinical_data', {})
        
        detected_flags = []
        
        # Evaluate BP readings
        bp_reading = clinical_data.get('bp_reading')
        if bp_reading:
            bp_flags = self._evaluate_bp_red_flags(bp_reading)
            detected_flags.extend(bp_flags)
        
        # Evaluate symptoms
        symptoms = clinical_data.get('symptoms', [])
        if symptoms:
            symptom_flags = self._evaluate_symptom_red_flags(symptoms)
            detected_flags.extend(symptom_flags)
        
        # Determine overall risk level
        risk_level = self._calculate_risk_level(detected_flags)
        
        # Create alerts if needed
        if detected_flags:
            for flag in detected_flags:
                await self._create_clinical_alert(patient_id, flag)
        
        # Execute immediate escalations if critical
        critical_flags = [f for f in detected_flags if f['severity'] == 'critical']
        if critical_flags:
            await self._execute_immediate_escalation(patient_id, critical_flags)
        
        return AgentResponse(
            response_id=str(uuid.uuid4()),
            correlation_id=message.correlation_id,
            status="SUCCESS",
            result={
                "red_flags_detected": len(detected_flags) > 0,
                "risk_level": risk_level,
                "detected_flags": detected_flags,
                "immediate_action_required": len(critical_flags) > 0
            }
        )
    
    def _evaluate_bp_red_flags(self, bp_reading: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Evaluate BP reading for red flags"""
        flags = []
        systolic = bp_reading.get('systolic', 0)
        diastolic = bp_reading.get('diastolic', 0)
        
        # Critical hypertension
        if systolic >= 200 or diastolic >= 120:
            flags.append({
                "type": "hypertensive_emergency",
                "severity": "critical",
                "description": f"Severe hypertension: {systolic}/{diastolic} mmHg",
                "escalation_required": "immediate",
                "recommended_action": "Emergency services and immediate hospital assessment"
            })
        elif systolic >= 180 or diastolic >= 110:
            flags.append({
                "type": "severe_hypertension", 
                "severity": "critical",
                "description": f"Severe hypertension: {systolic}/{diastolic} mmHg",
                "escalation_required": "urgent",
                "recommended_action": "Same-day GP assessment"
            })
        
        return flags
    
    async def health_check(self) -> Dict[str, Any]:
        """Red Flag agent health check"""
        return {
            "status": "healthy",
            "timestamp": datetime.utcnow().isoformat(),
            "agent": self.agent_name,
            "monitoring": {
                "bp_thresholds": self.alert_thresholds["critical_bp"],
                "symptom_monitoring": len(self.alert_thresholds["symptom_flags"]),
                "escalation_protocols": len(self.escalation_protocols)
            },
            "escalation_ready": True
        }
```

## Common Agent Utilities

### Error Handling and Resilience

```python
from functools import wraps
import asyncio
from typing import Callable, Any

def circuit_breaker(failure_threshold: int = 5, recovery_timeout: int = 60):
    """Circuit breaker decorator for agent methods"""
    def decorator(func: Callable) -> Callable:
        func._circuit_breaker_failures = 0
        func._circuit_breaker_last_failure = None
        func._circuit_breaker_state = "CLOSED"  # CLOSED, OPEN, HALF_OPEN
        
        @wraps(func)
        async def wrapper(*args, **kwargs):
            # Check circuit breaker state
            if func._circuit_breaker_state == "OPEN":
                if (datetime.utcnow() - func._circuit_breaker_last_failure).seconds > recovery_timeout:
                    func._circuit_breaker_state = "HALF_OPEN"
                else:
                    raise Exception("Circuit breaker is OPEN")
            
            try:
                result = await func(*args, **kwargs)
                
                # Reset on success
                if func._circuit_breaker_state == "HALF_OPEN":
                    func._circuit_breaker_failures = 0
                    func._circuit_breaker_state = "CLOSED"
                
                return result
                
            except Exception as e:
                func._circuit_breaker_failures += 1
                func._circuit_breaker_last_failure = datetime.utcnow()
                
                if func._circuit_breaker_failures >= failure_threshold:
                    func._circuit_breaker_state = "OPEN"
                
                raise e
        
        return wrapper
    return decorator
```

### Telemetry and Monitoring

```python
class AgentTelemetry:
    def __init__(self, telemetry_client, agent_name: str):
        self.telemetry_client = telemetry_client
        self.agent_name = agent_name
    
    def track_agent_execution(self, action: str, duration: float, success: bool, **kwargs):
        """Track agent execution metrics"""
        self.telemetry_client.track_event(
            name="AgentExecution",
            properties={
                "agent": self.agent_name,
                "action": action,
                "success": str(success),
                "environment": "demo",
                "is_dummy_data": "true",
                **{k: str(v) for k, v in kwargs.items()}
            },
            measurements={
                "duration_ms": duration * 1000
            }
        )
    
    def track_clinical_event(self, event_type: str, patient_id: str, severity: str = "normal"):
        """Track clinical events for safety monitoring"""
        self.telemetry_client.track_event(
            name="ClinicalEvent",
            properties={
                "agent": self.agent_name,
                "event_type": event_type,
                "patient_id": f"DUMMY-{patient_id}",  # Ensure dummy data marking
                "severity": severity,
                "is_dummy_data": "true"
            }
        )
    
    def track_safety_alert(self, alert_type: str, urgency: str, resolved: bool = False):
        """Track safety alerts for monitoring"""
        self.telemetry_client.track_event(
            name="SafetyAlert",
            properties={
                "agent": self.agent_name,
                "alert_type": alert_type,
                "urgency": urgency,
                "resolved": str(resolved),
                "is_dummy_data": "true"
            }
        )
```

## Deployment Configuration

### Agent Dockerfile Template

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy agent code
COPY . .

# Create non-root user
RUN groupadd -r agent && useradd -r -g agent agent
RUN chown -R agent:agent /app
USER agent

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Run agent
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Azure AI Foundry Deployment

```yaml
# deployment-config.yml for each agent
apiVersion: v1
kind: ConfigMap
metadata:
  name: {agent-name}-config
data:
  AGENT_NAME: "{agent-name}"
  FHIR_ENDPOINT: "https://fhir-mybp-demo.azurehealthcareapis.com"
  LOG_LEVEL: "INFO"
  ENVIRONMENT: "demo"
  DUMMY_DATA_ONLY: "true"

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {agent-name}-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: {agent-name}
  template:
    metadata:
      labels:
        app: {agent-name}
    spec:
      containers:
      - name: {agent-name}
        image: acrmybpdemo.azurecr.io/agents/{agent-name}:latest
        ports:
        - containerPort: 8000
        envFrom:
        - configMapRef:
            name: {agent-name}-config
        env:
        - name: AZURE_CLIENT_ID
          valueFrom:
            secretKeyRef:
              name: azure-credentials
              key: client-id
        - name: AZURE_CLIENT_SECRET
          valueFrom:
            secretKeyRef:
              name: azure-credentials
              key: client-secret
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5
```

---

**This implementation guide provides comprehensive specifications for developing each agent in the My BP system using Azure AI Foundry with dummy data for demonstration purposes only.**