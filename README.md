# caelestia-nightlight

Luz nocturna para la barra de Caelestia.

Uso la compu hasta tarde y la pantalla blanca me estaba matando los ojos. Probé f.lux, pero no funciona en Hyprland, y gammastep lo tenía que estar prendiendo y apagando a mano. Así que me hice esto: un icono en la barra que pone la pantalla más cálida cuando se va el sol y la deja normal de día. Si en algún momento la quiero más o menos cálida, la muevo yo y se queda así hasta que le diga que vuelva a automático.

Funciona con todo lo que tengas en pantalla (videos, juegos, el navegador) porque usa hyprsunset por debajo.

## Qué hace

- Se pone cálida sola al atardecer y vuelve a normal al amanecer, poco a poco (en una hora más o menos), no de golpe.
- Pasas el ratón por el icono y sale un panel para subir o bajar el filtro, con tres botones rápidos: lectura, noche y muy cálida.
- Clic en el icono lo prende o lo apaga. Con la rueda del ratón encima lo subes o lo bajas.
- También trae un botón para los ajustes rápidos.
- Si lo cambias a mano se queda así aunque reinicies, hasta que le des a "volver a automático".

Las horas del sol las calcula en la misma compu con la ubicación que le pongas. No usa internet.

## Ojo

Esto es un plugin y el sistema de plugins de Caelestia todavía no está terminado (está en el PR caelestia-dots/shell#1703). Lo hice siguiendo ese PR, así que puede que haya que cambiar algo cuando lo saquen.

Necesitas Hyprland y `hyprsunset` 0.4 o más nuevo. Si hyprsunset no está corriendo, el plugin lo abre solo.

## Instalar

```sh
git clone https://github.com/Asced1807/caelestia-nightlight ~/.config/caelestia/plugins/nightlight
```

Después lo activas en la página de plugins y lo pones donde lo quieras:

- En la barra: `{ "id": "nightLight", "enabled": true }` dentro de `bar.entries`
- En los ajustes rápidos: `{ "id": "nightLight", "enabled": true }` dentro de `utilities.quickToggles`

En los ajustes del plugin puedes cambiar la temperatura de noche (viene en 3400 K), cuánto dura el cambio, y tu latitud y longitud. Si no pones la longitud la saca de tu zona horaria, igual que hace f.lux.

## Desde la terminal

```sh
qs -c caelestia ipc call nightLight toggle      # prender / apagar
qs -c caelestia ipc call nightLight warmer      # más cálida
qs -c caelestia ipc call nightLight cooler      # menos cálida
qs -c caelestia ipc call nightLight set 3000    # una temperatura exacta
qs -c caelestia ipc call nightLight automatic   # volver a automático
qs -c caelestia ipc call nightLight get         # ver cuánto tiene ahora
```

## English

A night light plugin for Caelestia. It warms up the screen after sunset and goes back to normal in the morning, with a slow fade. You can also change it by hand from the bar (slider, scroll or presets) and it stays like that until you set it back to automatic. Uses hyprsunset.

It's built on the plugin system from caelestia-dots/shell#1703, which isn't merged yet, so it may need changes later. Install it by cloning into `~/.config/caelestia/plugins/nightlight`, then add `nightLight` to `bar.entries` and/or `utilities.quickToggles`.

## Autor

Hecho por Elvin Coronado Reyes ([@Asced1807](https://github.com/Asced1807)).

## Licencia

BSD 3-Clause
