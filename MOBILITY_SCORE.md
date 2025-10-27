# WiFi Mobility Score: Technical Overview

**Version:** 1.0  
**Date:** October 2025  
**Author:** wlan-autoroam Project

---

## Executive Summary

The WiFi Mobility Score is a comprehensive 0-100 point scoring algorithm designed to evaluate wireless network quality specifically for roaming scenarios. Unlike traditional WiFi assessments that focus solely on signal strength, this scoring system emphasizes **configuration consistency**, **RF planning excellence**, and **actual roaming performance** to provide actionable insights for network administrators.

The algorithm has been designed with enterprise WiFi deployments in mind, where seamless roaming is critical for voice, video, and real-time applications.

---

## Design Philosophy

### Core Principles

1. **Performance is Paramount**: No amount of perfect configuration matters if roaming actually fails. Performance acts as a key factor in the overall assessment.

2. **Configuration Consistency Matters**: Inconsistent AP configurations (different k/v/r support, mismatched channel widths, varying security) create unpredictable roaming behavior.

3. **RF Health Over Signal Strength**: Proper channel planning, appropriate channel widths, and low utilization are more important than raw RSSI values.

4. **Normalized Scoring**: Penalties scale proportionally to deployment size - a 100-AP network isn't unfairly penalized compared to a 2-AP network.

5. **Actionable Warnings**: Every deduction comes with an explanation of what's wrong and why it matters.

---

## Scoring Architecture

### Category Overview

The mobility score evaluates six key areas of WiFi deployment quality:

| Category | Focus Area |
|----------|------------|
| **Infrastructure** | 802.11k/v/r roaming protocol deployment |
| **Consistency** | Configuration uniformity across APs |
| **Performance** | Actual roaming success and speed |
| **RF Health** | Channel planning and spectrum usage |
| **Technology** | WiFi generation and security features |
| **Security** | Authentication method strength |

Each category is independently assessed and contributes to the overall score based on configurable weights that reflect real-world operational priorities.

---

## Category Breakdown

### 1. Performance

Performance evaluation focuses on two critical metrics:

**Success Rate**
- Measures the percentage of successful roaming attempts
- Accounts for complete failures, timeouts, and authentication issues
- Linear scoring based on success percentage

**Roam Speed**
- Evaluates average roaming latency
- Considers application requirements:
  - VoIP/Video: Requires minimal disruption
  - Interactive Apps: Moderate tolerance
  - Background Apps: Higher tolerance acceptable
- Uses industry-standard thresholds for scoring

Performance plays a unique role in the overall score - it acts as a quality multiplier rather than a simple additive component. This ensures that networks with broken roaming receive appropriately low scores regardless of configuration quality.

---

### 2. Infrastructure - Roaming Amendments

Evaluates deployment of 802.11k/v/r protocols, which are essential for modern WiFi roaming:

**802.11k (Radio Resource Measurement)**
- Enables neighbor AP discovery
- Reduces client scanning overhead
- Provides channel load information

**802.11v (BSS Transition Management)**
- Allows network-directed roaming
- Enables AP load balancing
- Improves client steering decisions

**802.11r (Fast BSS Transition)**
- Accelerates authentication during roaming
- Critical for enterprise (802.1X) environments
- Less impactful for PSK/SAE networks

Scoring methodology differs between Enterprise (802.1X) and Personal (PSK/SAE) networks, as 802.11r provides significant value only when authentication servers are involved.

Partial deployments receive proportional scores to encourage incremental improvements.

---

### 3. Consistency

Configuration uniformity is critical for predictable roaming behavior. The assessment prioritizes based on operational impact:

**Priority 1: Security Uniformity**
- Inconsistent security configurations can cause roaming failures
- Clients may refuse to roam between different auth methods
- WPA2/WPA3 transition mode receives partial credit

**Priority 2: Channel Width Uniformity**
- Clients expect consistent channel widths within a frequency band
- Mismatches cause re-association delays
- Evaluated independently per band (2.4/5/6 GHz)

**Priority 3: Protocol Uniformity**
- Mixed k/v/r deployment means some APs can't participate in assisted roaming
- Creates inconsistent user experience
- Partial uniformity receives proportional scoring

**Priority 4: Data Rate Uniformity**
- Inconsistent basic rates cause hesitation before roaming
- Less critical than security/width/protocol consistency
- Differentiated penalties for basic vs. supported rate mismatches

---

### 4. RF Health

RF planning quality is foundational to good roaming performance.

**Clean Channel Planning**
- Non-overlapping channel usage
- Proper channel spacing (1/6/11 on 2.4GHz)
- Band-specific evaluation

**Appropriate Channel Widths**
- 2.4GHz: 20MHz recommended (40MHz causes interference)
- 5GHz: 80MHz typical, 160MHz+ evaluated based on deployment
- 6GHz: 160MHz typical, 320MHz evaluated for appropriateness
- Severity-based penalties for problematic configurations

**Channel Utilization** (when QBSS data available)
- Average utilization percentage
- Distribution of highly-loaded APs
- Thresholds based on real-world performance impact

When QBSS data is unavailable, scoring focuses entirely on channel planning and width selection to ensure fair evaluation.

---

### 5. Technology

Evaluates WiFi generation adoption and legacy protocol usage.

**WiFi Generation Assessment**
- WiFi 7/6E/6: Modern features (OFDMA, BSS coloring, TWT)
- WiFi 5: Mature, widely deployed
- WiFi 4: Aging but functional
- Mixed deployments receive proportional scores

**Security Generation Tier**
- WPA3: Modern encryption and authentication
- WPA2: Industry standard
- WPA1: Deprecated, security risk
- Open: No encryption at all - still commonly used today but it won't earn any points

**Legacy Rate Detection**
- 802.11b rates (1/2 Mbps) consume excessive airtime
- Should be disabled on modern networks
- Penalty applied when detected

---

### 6. Security

Authentication method strength evaluation based on best-in-class industry standards:

**Enterprise (802.1X)**
- WPA3-Enterprise: Best available security
- WPA2-Enterprise: Industry standard
- Per-user authentication
- Centralized credential management

**Personal (PSK/SAE)**
- WPA3-Personal (SAE): Modern, less vulnerabilities than WPA2.
- WPA2-Personal (PSK): Acceptable for small deployments
- Shared password model has inherent limitations

**Guest/Open**
- OWE (Enhanced Open): Encrypted but no authentication
- Open: No encryption - no points!

Scoring reflects the security level while acknowledging that different deployment types have different requirements.

---

## Grading Scale

Final scores are converted to letter grades for intuitive understanding:

| Grade | Score Range | Interpretation |
|-------|-------------|----------------|
| Excellent | 86-100 | Excellent - Production-ready enterprise WiFi |
| Good | 71-85 | Good - Solid network with optimization opportunities |
| Fair | 51-70 | Fair - Functional with notable issues |
| Poor | 21-50 | Poor - Significant problems requiring remediation |
| Awful | 0-20 | Failing - Critical issues making network unsuitable |

---

## Warning System

The scoring system provides actionable feedback through category-specific warnings:

### Infrastructure Warnings
- Missing or partial k/v/r deployment
- Identifies specific gaps in roaming protocol support

### Consistency Warnings
- Security configuration mismatches
- Channel width inconsistencies per band
- Data rate configuration issues

### RF Health Warnings
- Channel overlap detection
- Inappropriate channel width usage
- High utilization alerts

### Technology Warnings
- Aging WiFi generation issues
- WPA1 protocol detection
- Legacy rate usage

### Security Warnings
- Open network detection
- Weak authentication methods
- Recommended upgrades

Warnings are designed to guide administrators toward specific remediation actions.

---

## Use Cases

### 1. Network Validation

Post-deployment verification:
- Confirm AP configuration consistency
- Validate RF planning
- Verify roaming functionality
- Target: Score ≥90 for production environments

### 2. Troubleshooting

Problem identification:
- Warnings highlight specific issues
- Category breakdown shows weak areas
- Enables focused remediation

### 3. Benchmarking

Comparative analysis:
- Pre/post upgrade assessment
- Multi-site comparison
- Vendor evaluation

### 4. Regression Testing

Automated validation:
- Post-firmware update verification
- Configuration drift detection
- New AP compatibility testing

---

## Methodology Highlights

### Normalization

All penalty calculations use percentage-based methods to ensure fairness across deployment sizes. A network with 100 APs and 10% misconfiguration receives the same penalty as a 10-AP network with 10% misconfiguration.

### Performance Multiplier Approach

Rather than adding performance points to configuration points, performance acts as a quality multiplier. This correctly reflects that configuration quality only matters if roaming actually works.

Traditional approach:
```
config_score + performance_score = total
Problem: Perfect config (90) + broken roaming (0) = 90/100 (A-)
```

Our approach:
```
performance_multiplier × config_score = total
Result: Perfect config × 0% performance = 0/100
```

### Piecewise Linear Interpolation

Roaming speed scoring uses application-aware breakpoints rather than simple linear scaling. This creates natural grade boundaries aligned with real-world application requirements.

### Adaptive Scoring

Scoring adapts to available data:
- Networks without QBSS data aren't penalized
- PSK networks don't score 802.11r
- Points redistribute to ensure fair maximum scores

---

## Best Practices

### Achieving High Scores

**Infrastructure (k/v/r)**
- Deploy 802.11k/v on all APs
- Enable 802.11r for Enterprise networks
- Ensure consistent deployment across all APs

**Consistency**
- Standardize security configurations
- Use consistent channel widths per band
- Align protocol support across all APs
- Standardize rate configurations

**RF Health**
- Use non-overlapping channels
- Apply appropriate channel widths for each band
- Monitor and manage channel utilization
- Avoid 40MHz on 2.4GHz

**Technology**
- Deploy modern WiFi generations (6/6E/7)
- Disable 802.11b legacy rates
- Use WPA3 when possible
- Maintain consistent firmware versions

**Security**
- Use 802.1X for enterprise environments
- Deploy WPA3 for new installations
- Avoid Open networks except for specific guest use cases

---

## Limitations

### Current Scope

- **Single SSID Assessment**: Multi-SSID environments require separate evaluation per SSID
- **Configuration-Based**: Evaluates AP configuration, not client experience
- **No Spatial Analysis**: Doesn't consider AP placement or coverage patterns
- **Roaming-Focused**: Optimized for roaming scenarios, not general WiFi quality

### Data Requirements

- Requires roaming test data for performance scoring
- Benefits from QBSS data for utilization assessment
- Needs complete AP configuration information

---

## Target Scores by Deployment Type

| Deployment Type | Target Score | Rationale |
|----------------|--------------|-----------|
| Enterprise Production | 90+ | Mission-critical WiFi requires excellence |
| SMB Production | 80+ | Acceptable for business use |
| Home/Small Office | 70+ | Functional roaming capability |
| Development/Lab | 60+ | Testing environment |

---

## Conclusion

The WiFi Mobility Score provides a comprehensive, consistent method for evaluating wireless network quality specifically for roaming scenarios. By emphasizing actual performance alongside configuration quality, providing actionable warnings, and using normalized scoring methods, it delivers practical value to network administrators seeking to optimize their WiFi deployments.

The system balances technical rigor with operational practicality, making it suitable for enterprise validation, troubleshooting workflows, and ongoing network monitoring.

---

## Appendix: Common Warning Triggers

| Warning Category | Typical Trigger | Recommended Action |
|-----------------|-----------------|-------------------|
| k/v/r deployment | Partial or missing protocol support | Enable on all APs |
| Channel overlap | Non-standard channel usage | Use 1/6/11 on 2.4GHz |
| Wide channels | 40MHz on 2.4GHz | Reduce to 20MHz |
| Width mismatch | Mixed widths in single band | Standardize per band |
| Legacy rates | 1/2 Mbps detected | Disable 802.11b rates |
| WPA1 detection | Old security protocol | Upgrade to WPA2/WPA3 |
| Open network | No encryption | Implement WPA2/WPA3 |
| Mixed generations | WiFi 4/5/6 mix in same deployment | Plan phased upgrades |

---

**For More Information:**

This scoring methodology is implemented in the wlan-autoroam WiFi roaming analysis tool. For licensing inquiries or additional technical details, please contact the project maintainer.

**Document Version:** 1.0 (Public) - October 2025  
**Copyright:** © 2025 wlan-autoroam Project. All rights reserved.
