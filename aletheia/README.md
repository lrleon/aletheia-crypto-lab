# Aletheia Crypto Lab

Aletheia es un laboratorio prudente de investigación de mercados cripto.

**Atención: Este proyecto NO es financial advice.**
**NO es un bot autónomo de trading.**

## Reglas de Oro

- **Spot only.**
- **No futures, no margin, no leverage.**
- **No withdrawals.**
- **Dry-run por defecto.** (`dry_run: true`)

## Estado del Proyecto

**Fase 0:** Preparación y seguridad conceptual.

## Instalación

Ruby recomendado:

```bash
ruby 3.3.10
```

El proyecto fija esta versión en `.ruby-version`. Si hay varios gestores instalados, preferir `rbenv` para este repositorio.

1. Instalar dependencias de Ruby:
   ```bash
   ruby -S bundle install
   ```

2. Ejecutar las pruebas unitarias:
   ```bash
   ruby -S bundle exec rake spec
   ```

3. Ejecutar el diagnóstico de seguridad:
   ```bash
   bin/aletheia doctor
   ```

## Reglas para Asistentes de IA

- Las IAs no pueden ejecutar `git commit`, `git push`, crear tags ni releases.
- La atribución de commits pertenece exclusivamente al propietario humano.
- Las IAs no deben habilitar trading real ni inventar APIs de Aleph_w.
