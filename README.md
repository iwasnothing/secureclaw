# secureclaw
Building an Unhackable, Zero-Cost AI Agent: The "Secure Enclave" Architecture
Running an autonomous AI agent 24/7 is the holy grail for many developers, but it typically comes with two massive deal-breakers: Security Risks and Runaway Costs. A standard agent setup usually involves giving a bot full internet access and a credit card-linked API key. If that agent gets hacked, hallucinates, or enters an infinite loop, it can exfiltrate your secrets or burn through hundreds of dollars in hours.

We have built a better way: a Zero-Trust Enclave running on local hardware. This architecture creates a "digital faraday cage" that guarantees maximum security with zero operational token costs.

The Architecture: A "Digital Faraday Cage"
The core philosophy of this setup is Isolation. Instead of a single container with internet access, we use a multi-container Docker array where the Agent is physically trapped in a network with no gateway.

1. The Trap: internal: true

In a standard Docker setup, containers can talk to the internet by default. In our docker-compose.yml, we define a specific network called secure_enclave with the flag internal: true.

YAML
networks:
  secure_enclave:
    driver: bridge
    internal: true # THE TRAP: No internet access
This removes the default gateway. The Agent container (agent-box) cannot ping Google, cannot download malware, and cannot connect to a Command-and-Control (C2) server. It is effectively air-gapped.

2. The Brain: LiteLLM Sidecar

If the agent has no internet, how does it think? It connects to a LiteLLM Sidecar (litellm).

Role: Acts as an API Gateway.

Security: It sanitizes requests and forwards them only to your local vLLM server (e.g., Qwen-30B running on a DGX) via the Docker host gateway.

Cost: Because it routes to your local GPU, every token is free. You can let the agent "think" for hours or read entire codebases without a bill.

3. The Mouth: Squid Proxy Sidecar

The only way the agent is allowed to communicate with the outside world is through a strictly whitelisted Squid Proxy (secure-proxy).

Role: Acts as a firewall for outbound traffic.

Configuration: We configure it to allow traffic only to api.telegram.org.

Benefit: If the agent tries to connect to hacker.com or upload your code to Pastebin, the connection is killed instantly by the proxy.

Why This Wins
🔒 Security: Defense in Depth

This architecture employs multiple layers of security that cloud-based agents cannot match:

Network Isolation: The internal: true flag is a kernel-level restriction. The agent physically cannot find a route to the internet.

Capability Dropping: We use cap_drop: [ALL] to strip the container of all Linux root capabilities. Even if an attacker gains code execution, they cannot modify network settings or mount drives.

Data Privacy: Your data never leaves the local Docker network. Prompts go to your local GPU, not to OpenAI or Anthropic.

💰 Cost: The 24/7 Advantage

Cloud models charge by the token (input and output). An autonomous agent runs in a continuous loop: Think → Act → Observe → Think.

The Cloud Trap: A simple error loop can burn $50–$200/day on GPT-4.

The Local Advantage: By running Qwen-30B on local hardware, your marginal cost is $0. You can run 10 agents in parallel for the cost of electricity.

🛠️ Extensibility: Custom Skills (The Aider Example)

Most platforms force you to use generic, black-box tools. This architecture allows for powerful, custom integrations.

In this setup, we didn't just install a "coding plugin." We integrated Aider—a sophisticated AI coding tool—as a custom skill.

How it works: When the agent needs to write code, it doesn't try to blindly edit files. It invokes the aider-skill.

Safety: Because Aider runs inside the secure_enclave, it inherits all the security protections. It can modify your local workspace, but it cannot upload that code to the cloud.

Conclusion
This architecture proves that you don't need to sacrifice capability for security. By using Docker networking features like internal: true and sidecar proxies, you have built a system where the AI is smart enough to be useful, but isolated enough to be safe.
