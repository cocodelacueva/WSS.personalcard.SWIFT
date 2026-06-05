# Ideas para v2 — Personal Card

Roadmap de ideas a futuro. Notas técnicas + alternativas evaluadas.

---

## 1. Capturar datos de quien escanea mi QR

### Problema
Tal cual lo pensé originalmente, **no es técnicamente posible**: un QR es información estática y cuando alguien lo escanea, su teléfono lo lee local. No hay canal de vuelta, nunca me entero de quién escaneó.

### Alternativas reales

#### a) Landing page con form opcional
- El QR apunta a una URL mía (ej: `whitesuit.com/connect?id=abc`)
- La persona, si quiere, deja email/teléfono en un form
- Requiere **backend** (servidor + base de datos)
- Costo de mantenimiento alto para una app personal

#### b) ⭐ Modo "intercambio bidireccional" (RECOMENDADO)
- La app suma la funcionalidad de **escanear QRs de otros**
- Cuando me encuentro con alguien que tiene la app o cualquier QR estándar (vCard), mi app escanea, parsea y guarda
- Es lo que hacen LinkedIn QR, apps tipo Cardly, etc.
- **100% local, sin servidor, sin costos**

#### c) NFC tap-to-share
- Acercar dos iPhones para intercambiar datos
- Más rápido que QR pero requiere ambos lados con la app o NFC tag programado
- Buena adición posterior, no primera prioridad

---

## 2. Block de notas / CRM personal

Totalmente factible y se hace local. Modelo:

- Cada vez que escaneo a alguien (idea 1.b), se crea automáticamente un registro con timestamp
- En ese registro puedo agregar: notas libres, TODOs, tags, foto opcional
- Vista de lista cronológica: "Quién conocí este mes"
- Búsqueda por nombre, empresa, tag

### Stack técnico sugerido
- **SwiftData** para persistencia local (API moderna, reemplazo de Core Data)
- Sigue el patrón actual: todo local, nada de cuentas ni cloud
- Opcional: sync con iCloud usando `CloudKit` + SwiftData (zero-config para el usuario)

---

## 3. Diseño alternativo con logo de empresa

Agregar un segundo "tema" / layout que incluya el logo de la empresa, elegible desde la app de Fotos.

### UX propuesta
- En `EditView`, nueva sección **"Diseño"** con un picker:
  - **Diseño 1** — el actual (sin logo)
  - **Diseño 2** — con logo arriba del QR o como header
- En el Diseño 2, botón **"Elegir logo desde Fotos"**
- Preview en vivo de cómo queda
- Opción para quitar el logo

### Stack técnico

- **`PhotosPicker`** (SwiftUI nativo desde iOS 16) — no requiere permiso explícito de fotos, Apple lo maneja con un selector seguro
- El logo se guarda como `Data` en `SharedStorage.defaults` (mismo App Group que el resto), así también lo ve el Watch
- Una nueva clave en `StorageKeys`: `logoImageData`
- Una nueva clave: `selectedDesign` con enum `CardDesign { .design1, .design2 }`

### Consideraciones

- **Tamaño del logo guardado**: redimensionar a max 512x512 antes de guardar, para no inflar UserDefaults (que tiene límite de ~4MB por valor en App Groups)
- **WatchConnectivity**: `updateApplicationContext` tiene límite de payload (~262KB típicamente). Si el logo + QR se pasa de eso, hay que usar `transferFile` en vez de `updateApplicationContext` para el logo
- **Privacy manifest**: `PhotosPicker` **no** requiere agregar nada al privacy manifest ni al Info.plist (es el punto fuerte de esa API vs `PHPickerViewController` clásico)
- En watchOS, mostrar el logo escalado en el header o como complicación visual

### Permisos necesarios
- **Ninguno** — `PhotosPicker` no requiere `NSPhotoLibraryUsageDescription` porque corre fuera del sandbox de la app

---

## 4. Integraciones con apps de Apple

| App de Apple | ¿Posible? | Cómo |
|---|---|---|
| **Contactos** | ✅ Sí | Framework `Contacts` — guardar contacto directo en la libreta |
| **Recordatorios** | ✅ Sí | Framework `EventKit` — crear TODO desde mi app |
| **Calendario** | ✅ Sí | Framework `EventKit` — crear eventos / follow-ups |
| **Mail** | ✅ Limitado | `MessageUI` para pre-componer un email; no se puede leer inbox |
| **Apple Notes** | ❌ No | Apple no expone API pública para crear notas |
| **Mensajes/iMessage** | ✅ Sí | `MessageUI` para pre-componer SMS |
| **Share Sheet** | ✅ Sí | El usuario decide a dónde mandar (incluye Notes) |

Para Apple Notes la mejor alternativa: tener las notas dentro de mi app y exportarlas con un Share Sheet (que sí puede mandar a Notes del lado del usuario).

---

## Propuesta concreta para v2

```
1. Scanner integrado
   - Botón "Escanear" en la pantalla principal
   - Detecta vCard estándar y QRs de "Personal Cards"
   - Guarda el contacto con timestamp

2. Historial / CRM personal
   - Lista de personas escaneadas
   - Cada una con: datos, notas libres, TODOs, tags
   - Búsqueda

3. Diseño 2 con logo de empresa
   - Picker de diseño en EditView
   - PhotosPicker para elegir logo
   - Sync del logo al Watch

4. Integraciones (opt-in, una por una)
   - "Guardar en Contactos" → Contacts framework
   - "Crear recordatorio de follow-up" → EventKit
   - "Agendar reunión" → EventKit (calendar)
   - "Enviar email" → MessageUI
   - "Compartir" → Share Sheet (incluye Apple Notes)
```

Esto convierte la app de "mostrar mi QR" → "networking tool personal".
Evolución natural, no rompe nada de v1, todo 100% local + privacidad-first.

---

## Orden sugerido de implementación

1. **Diseño 2 + PhotosPicker** (la más rápida de hacer, alto impacto visual, no toca arquitectura)
2. **Scanner** (sin esto las demás features no tienen de dónde alimentarse)
3. **Persistencia con SwiftData** (modelo de "Contact" + "Note" + "TODO")
4. **Lista/Historial** con search
5. **Integración con Contactos** (alto valor / esfuerzo bajo)
6. **Recordatorios + Calendario** (EventKit cubre los dos con el mismo permiso)
7. **Email pre-compuesto** (rápido de hacer)
8. **NFC tap-to-share** (extra polish, post-launch)

---

## Consideraciones de permisos (para Info.plist)

Cuando agregue cada feature voy a necesitar:

- `NSCameraUsageDescription` — para escanear QRs
- `NSContactsUsageDescription` — para guardar/leer contactos
- `NSCalendarsUsageDescription` y `NSRemindersUsageDescription` — para EventKit
- Actualizar `PrivacyInfo.xcprivacy` si cambia el uso de Required Reason APIs

---

## Versionado planeado

- **v1.x** — patches al QR + tipografías + sync
- **v2.0** — scanner + CRM local básico
- **v2.x** — integraciones con apps de Apple
- **v3.0** — sync iCloud opcional + NFC

---

_Última actualización: 2026-05-15_
