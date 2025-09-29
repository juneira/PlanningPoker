# PlanningPoker

## Architecture

```sh
Application Supervisor
├── GameManager (DynamicSupervisor)
│   ├── Game1 Supervisor
│   │   ├── GameServer (GenServer)
│   │   └── RoundManager Supervisor (DynamicSupervisor)
│   │       ├── Round1 (GenServer)
│   │       ├── Round2 (GenServer)
│   │       └── Round3 (GenServer)
│   └── Game2 Supervisor
│       ├── GameServer (GenServer)
│       └── RoundManager Supervisor (DynamicSupervisor)
│           ├── Round1 (GenServer)
│           └── Round2 (GenServer)
```
