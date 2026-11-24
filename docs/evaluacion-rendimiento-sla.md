# UTSJR — Unidad III — Evaluación de Rendimiento
**Ingeniería en Desarrollo y Gestión de Software | Ciclo 2025-2026**  
**Materia:** Proceso de Liberación y Monitoreo  
**Tema:** SLA / SLO / SLI / Presupuesto de Errores  

---

## 👥 Integrantes del Equipo

| # | Nombre Completo | N° Control |
|---|---|---|
| **1** | Eduardo Ochoa Almaraz | *(Coloca tu matrícula aquí)* |
| **2** | Gerardo Cruz Gudiño | *(Matrícula compañero 2)* |
| **3** | Fernando Pichardo | *(Matrícula compañero 3)* |
| **4** | *T.S.U DURAZNO MARTINEZ MIGUEL ANGEL
* | *(Matrícula integrante 4)* |

* **Aplicación:** **Centrix** (Sistema Integral de Gestión de Tickets, Recursos y Notificaciones Push)
* **Plataforma:** **Android** (con cliente Web complementario)

---

## 🎯 Objetivo
Aplicar los conceptos de niveles de servicio (SLA, SLO, SLI y presupuesto de errores) a la aplicación móvil Centrix, identificar las métricas de rendimiento, confiabilidad y disponibilidad pertinentes para su arquitectura (Flutter + Node.js/Express CQRS + Supabase + Firebase Cloud Messaging), y formular un plan de mejora basado en resultados.

---

## 📝 Actividad 1 — Niveles de Servicio

### 1.1 Conceptos Clave

| Concepto | Definición (en nuestras palabras) | Ejemplo concreto en Centrix |
| :--- | :--- | :--- |
| **SLI** *(Indicador de Nivel de Servicio)* | Es la métrica cuantitativa real obtenida en tiempo real que indica qué tan bien está funcionando un servicio específico en un periodo determinado (el "termómetro" del sistema). | El porcentaje de peticiones HTTP exitosas (código 2xx) para consultar tickets (`GET /api/tickets/mine`) que responden en menos de **500 ms** medido en los últimos 30 días. |
| **SLO** *(Objetivo de Nivel de Servicio)* | Es la meta o umbral interno acordado por el equipo de ingeniería para definir si el servicio es satisfactorio. Es más estricto que el SLA para tener margen de acción preventiva. | El **99.2%** de las notificaciones push por asignación de tickets emitidas por Firebase Admin deben ser entregadas al dispositivo Android en menos de **5 segundos**. |
| **SLA** *(Acuerdo de Nivel de Servicio)* | Es el compromiso legal y contractual formal firmado con el cliente o la dirección del negocio, donde se prometen garantías mínimas y penalizaciones (económicas o de soporte) si no se cumplen. | Compromiso formal de disponibilidad de la API de Centrix del **98.5% mensual** durante horario laboral (08:00 a 18:00 hrs). Si la disponibilidad cae por debajo, se otorga una bonificación del 15% en la mensualidad del servicio. |
| **Presupuesto de Errores** *(Error Budget)* | Es el margen permitido de fallas o degradación que el sistema puede tolerar antes de violar el SLO ($100\% - \text{SLO}$). Determina el balance entre velocidad de desarrollo y estabilidad operativa. | Con un SLO de disponibilidad del **99.0% mensual**, el presupuesto de errores es del **1.0%** (equivalente a **432 minutos** de indisponibilidad permitidos al mes para mantenimiento y despliegues). |

---

### 1.2 Jerarquía y Relación

Los cuatro conceptos forman una cadena de control y calidad continua:

$$\text{SLI (Medición Real)} \longrightarrow \text{SLO (Meta Interna)} \longrightarrow \text{Presupuesto de Errores (Margen)} \longrightarrow \text{SLA (Contrato Externo)}$$

1. **¿Cuál informa a cuál?**
   - El **SLI informa al SLO**: Los datos recolectados (SLI) se comparan contra la meta operativa (SLO) para saber si el sistema está rindiendo según lo planeado.
   - El **SLO informa y protege al SLA**: El SLO se establece con un estándar deliberadamente más alto que el SLA (ej. SLO del 99.2% vs SLA del 98.5%). De esta manera, si el rendimiento cae y se vulnera el SLO, el equipo recibe alertas preventivas y puede actuar **antes** de que se vulnere el SLA contractual con el cliente.
   - El **Presupuesto de Errores** se calcula a partir del SLO ($100\% - \text{SLO}$). Si el presupuesto se consume rápidamente, el equipo congela nuevas funciones y prioriza la estabilidad.

2. **¿Cuál es el acuerdo formal con el cliente?**
   - El **SLA (Service Level Agreement)** es el único documento con validez jurídica y consecuencias comerciales o económicas firmado entre los desarrolladores/proveedores y el cliente final.

---

### 1.3 Cálculo del Presupuesto de Errores

Para un SLO de disponibilidad del **99.0% mensual**:

| Pregunta | Cálculo / Respuesta |
| :--- | :--- |
| **Minutos totales en un mes (30 días)** | $30 \text{ días} \times 24 \text{ horas/día} \times 60 \text{ minutos/hora} =$ **$43,200 \text{ minutos}$** |
| **Minutos permitidos de inactividad (1 %)** | $43,200 \text{ minutos} \times 0.01 =$ **$432 \text{ minutos}$** *(equivalente a 7 horas con 12 minutos)* |
| **Si ya tuvieron 200 min de fallas, ¿cuánto les queda del presupuesto?** | $432 \text{ min} - 200 \text{ min} =$ **$232 \text{ minutos}$** restantes *(un $53.7\%$ del presupuesto inicial)* |

#### ¿Qué debería suceder si agotan el presupuesto de errores?
Si el equipo consume los 432 minutos de tolerancia antes de finalizar el mes:
1. **Congelamiento de Despliegues (Feature Freeze):** Se suspende la liberación de nuevas funcionalidades, pantallas o cambios estéticos en producción.
2. **Prioridad Absoluta a la Confiabilidad:** El 100% de la capacidad del equipo de desarrollo se reorienta a tareas de estabilidad: optimización de consultas SQL en Supabase, corrección de bugs críticos, ajuste de tiempos de espera en Dio/HTTP, e índices en la base de datos.
3. **Análisis Post-Mortem sin Culpas (Blameless Post-Mortem):** Se documenta la causa raíz de los 432 minutos de inactividad para implementar medidas correctivas permanentes.
4. **Reapertura de Despliegues:** Solo se reanuda la entrega de nuevas características cuando el sistema demuestre estabilidad durante un ciclo completo o comience el siguiente mes con presupuesto renovado.

---

## 📊 Actividad 2 — Métricas de Rendimiento de Centrix

Métricas estándar para aplicaciones móviles orientadas a la arquitectura de **Centrix (Flutter Mobile + Backend Express + Supabase + Firebase Cloud Messaging)**:

| Categoría | Métrica | ¿Qué mide? | Valor objetivo para Centrix |
| :--- | :--- | :--- | :--- |
| **Desempeño** | **Tiempo de inicio (Cold Start)** | Tiempo desde que el usuario pulsa el icono de Centrix hasta que el Dashboard o Login es completamente interactivo. | $\le \mathbf{1.8 \text{ segundos}}$ en dispositivos Android de gama media (ej. Samsung M12). |
| **Desempeño** | **Tiempo de respuesta API (Latencia)** | Tiempo de ida y vuelta (Round-Trip Time) en peticiones HTTP para carga de tickets y departamentos. | $\text{Percentil 95 (P95)} \le \mathbf{450 \text{ ms}}$ en red Wi-Fi y $\le \mathbf{800 \text{ ms}}$ en redes móviles 4G. |
| **Desempeño** | **Frames por segundo (UI / Jank Rate)** | Fluidez visual de Flutter en listas de tickets con scroll y apertura de modales; mide caídas de frames ($>16.6\text{ ms}$). | $\ge \mathbf{58 \text{ FPS}}$ promedio, con tasa de cuadros congelados (janky frames) $< \mathbf{1.0\%}$. |
| **Confiabilidad** | **Tasa de fallos (Crash Rate)** | Porcentaje de sesiones de usuario que terminan en cierre abrupto (crash nativo, excepción no capturada o ANR). | Tasa de sesiones libres de fallos $\ge \mathbf{99.8\%}$ (Crash rate $\le 0.2\%$). |
| **Confiabilidad** | **Tasa de errores HTTP (5xx)** | Porcentaje de llamadas desde la app móvil que reciben un código de error de servidor (500, 502, 503). | $\le \mathbf{0.3\%}$ del total de transacciones mensuales. |
| **Disponibilidad**| **Uptime del backend** | Porcentaje de tiempo que el servidor Express y la base de datos en Supabase están en línea y respondiendo. | $\ge \mathbf{99.5\%}$ mensual (máximo 3.6 horas de inactividad no planificada al mes). |
| **Disponibilidad**| **Tasa de entrega de Notificaciones Push (Métrica propia)** | Porcentaje de notificaciones críticas (asignación de tickets o cambios de estado) entregadas a los dispositivos en $<5\text{ s}$. | $\ge \mathbf{99.0\%}$ de entrega exitosa a los dispositivos vinculados vía FCM. |

---

## 🔗 Actividad 3 — Relación entre Métricas y Niveles de Servicio

| SLI (¿Qué mide?) | SLO (Meta interna del equipo) | ¿Incluir en el SLA? | Justificación breve |
| :--- | :--- | :---: | :--- |
| **Uptime mensual del Backend y Base de Datos** | $99.5\%$ de disponibilidad continua en el mes. | **SÍ** | Es el núcleo del servicio: si el backend está caído, ningún usuario en la empresa puede operar ni atender tickets. |
| **Tasa de éxito y latencia en Creación de Tickets con Evidencias** | $99.0\%$ de tickets creados con foto en $<1.5\text{ s}$. | **SÍ** | Representa el flujo crítico de valor (Core Business). El cliente contrata Centrix para registrar incidentes sin bloqueos. |
| **Tasa de sesiones móviles libres de caídas (Crash-Free Sessions)** | $\ge 99.5\%$ de sesiones sin cierres inesperados. | **SÍ** | Un crash continuo rompe la confianza y usabilidad de la herramienta en campo; se garantiza un umbral mínimo en el SLA ($99.0\%$). |
| **Fluidez de interfaz (FPS) en scroll de tickets** | Mantener $\ge 58\text{ FPS}$ en el $95\%$ del tiempo de renderizado. | **NO** | Es una métrica de calidad interna. Depende fuertemente del hardware y procesador del smartphone del usuario, variable fuera de nuestro control. |
| **Tiempo de arranque en frío (Cold Start)** | $\le 1.8\text{ s}$ en el 90% de los arranques. | **NO** | Está influenciada por la memoria RAM disponible en el teléfono y apps en segundo plano del usuario; incluirla en el SLA crearía contingencias legales injustas. |

### ¿Por qué no todos los SLI deben aparecer en el SLA con el cliente?
1. **Control y Responsabilidad Técnica:** Un SLA comercial solo debe incluir métricas sobre las cuales el proveedor de software tiene **control absoluto** (como la disponibilidad del servidor, la integridad de la base de datos y la tasa de error HTTP). Factores como los frames por segundo o la velocidad de apertura dependen del modelo del celular, temperatura o saturación de memoria del teléfono del usuario.
2. **Complejidad y Riesgo Legal Innecesario:** Cuantas más métricas se añaden a un contrato legal, mayor es la probabilidad de incurrir en disputas o penalizaciones por variables ajenas al servicio contratado.
3. **Foco en el Valor de Negocio:** El cliente corporativo no requiere auditar detalles técnicos como la tasa de refresco en Hertz o jank de widgets; le interesa que la plataforma esté **disponible, que no pierda datos y que las incidencias se reporten y atiendan rápido**.

---

## 🛠️ Actividad 4 — Plan de Mejora

### Escenario Hipotético
Tras la primera semana de salida a producción, se detecta que dos métricas cayeron por debajo de su meta:

| Métrica fuera de SLO | Valor actual (hipotético) | SLO definido | Causa probable | Acción de mejora | Plazo |
| :--- | :---: | :---: | :--- | :--- | :---: |
| **1. Tiempo de respuesta API en consulta de evidencias (`GET /evidences`)** | **$2.8 \text{ s}$** *(P95)* | $\le \mathbf{800 \text{ ms}}$ | Generación síncrona repetitiva de URLs firmadas en Supabase Storage sin memoria caché, y ausencia de índice en `ticket_attachments(ticket_id)`. | 1. Crear índice compuesto en Postgres: `CREATE INDEX idx_ticket_attachments_ticket_id ON ticket_attachments(ticket_id, created_at DESC)`.<br>2. Implementar caché en memoria (Redis/Node-cache con TTL de 4 min) para las URLs firmadas de 5 minutos, evitando re-firmar en cada petición. | **48 horas** *(Hotfix)* |
| **2. Tasa de entrega exitosa de Push Notifications (FCM)** | **$93.8\%$** | $\ge \mathbf{99.0\%}$ | Descarte silencioso en dispositivos Samsung por entrar en modo ahorro (Doze Mode) al no tener configurado canal de alta prioridad en el payload del backend, y tokens inválidos no purgados. | 1. Configurar en `NotificationService.js` la propiedad obligatoria `android: { priority: 'high', notification: { channelId: 'centrix_high_importance_channel' } }`.<br>2. Rutina de purga inmediata en `device_tokens` de tokens desinstalados (`registration-token-not-registered`). | **72 horas** |

---

### 📢 Comunicación con el Cliente

#### Estrategia
* **Proactiva:** Notificar antes de que el cliente experimente la molestia y levante quejas.
* **Transparente y orientada a la solución:** Reconocer la degradación sin tecnicismos innecesarios, garantizando que los datos están seguros y explicando los pasos de mitigación en curso.
* **Respeto a las cláusulas de SLA:** Aplicar bonificaciones automáticas si aplica.

#### Mensaje Oficial Redactado

> **Asunto:** Actualización sobre el rendimiento de la plataforma Centrix — Medidas correctivas en curso
> 
> Estimado equipo directivo y usuarios de Centrix:
> 
> Durante nuestras revisiones continuas de telemetría de las últimas 48 horas, hemos identificado una ralentización temporal en los tiempos de carga al visualizar evidencias fotográficas en el módulo de tickets, registrando demoras de hasta 2.8 segundos frente a nuestro estándar comprometido de 800 ms.
> 
> Queremos darles total certeza de que **la integridad de su información, la recepción de tickets y la asignación de soporte no han sufrido ninguna pérdida ni afectación de seguridad**.
> 
> Nuestro equipo de ingeniería ya ha implementado un paquete de optimización en los índices de la base de datos y un sistema de almacenamiento temporal acelerado, el cual restablecerá los tiempos de respuesta óptimos en un plazo máximo de 24 horas.
> 
> En estricto apego a nuestro Acuerdo de Nivel de Servicio (SLA) y en agradecimiento a su confianza, se aplicará de forma automática una **bonificación del 10% en su siguiente factura mensual**.
> 
> Continuaremos monitoreando los indicadores las 24 horas del día. Si experimentan alguna consulta adicional, nuestro canal preferente de soporte se encuentra totalmente abierto.
> 
> Atentamente,  
> **Equipo de Operaciones y Confiabilidad de Software — Centrix**

---

### 💭 Reflexión de Equipo

> **¿Qué aprendieron sobre la importancia de definir SLO antes de salir a producción, y no después de que algo falla?**
>
> *"Comprendimos que definir los SLO de forma previa no es un trámite burocrático, sino la brújula técnica que alinea al equipo de desarrollo con las expectativas reales de los usuarios. Establecer los SLO con anticipación nos otorga un criterio cuantitativo e indiscutible sobre qué significa que la aplicación 'funcione bien', eliminando opiniones subjetivas.*
> 
> *Asimismo, contar con un Presupuesto de Errores preventivo permite tomar decisiones maduras de ingeniería: nos indica exactamente cuándo tenemos margen para innovar y lanzar nuevas pantallas, y cuándo debemos frenar en seco para reforzar la infraestructura antes de que ocurra una catástrofe. Definir métricas después de un fallo únicamente sirve para maquillar el problema o actuar en modo pánico; definirlas antes establece una cultura sólida de Ingeniería de Confiabilidad del Sitio (SRE), donde los sistemas se diseñan para ser tolerantes a fallos desde la primera línea de código."*

---

## 📚 Referencias Bibliográficas (Formato APA 7ma Edición)

1. **Beyer, B., Jones, C., Petoff, J., & Murphy, N. R.** (2016). *Site Reliability Engineering: How Google Runs Production Systems* (1.ª ed.). O'Reilly Media. https://sre.google/sre-book/table-of-contents/
2. **Google Cloud.** (2023). *SRE fundamentals: SLIs, SLOs, and SLAs*. Google Cloud Architecture Center. https://cloud.google.com/architecture/devops/devops-measurement-reliability
3. **Android Developers.** (2024). *Android vitals: Métricas de rendimiento, inicios y estabilidad en apps móviles*. Google Developers Documentation. https://developer.android.com/topic/performance/vitals
4. **Firebase.** (2024). *Firebase Cloud Messaging HTTP v1 API delivery and performance guidelines*. Google Firebase Documentation. https://firebase.google.com/docs/cloud-messaging
