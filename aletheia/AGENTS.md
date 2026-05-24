# Reglas para Agentes de IA (AGENTS)

Todos los agentes de IA que asistan en este proyecto deben seguir estas reglas:

1. **NO GIT:** No ejecutar `git commit`, `git push`, `git tag`, `git push --tags`, crear releases ni hacer merge de PRs. La atribución de commits pertenece al propietario humano.
2. **Seguridad:** Mantener siempre defaults conservadores. `dry_run: true`, `trading_enabled: false`. No habilitar trading real.
3. **Restricciones de Mercado:** Solo Spot. No futures, no margin, no leverage, no withdrawals.
4. **C++ & Aleph_w:** No inventar APIs de Aleph_w. Revisar documentación/headers locales.
