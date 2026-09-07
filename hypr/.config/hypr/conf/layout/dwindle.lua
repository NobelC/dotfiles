-- =====================================================================
-- LAYOUT: DWINDLE (Binary Space Partitioning)
-- Configuración del algoritmo BSP para el compositor
-- =====================================================================

hl.config({
  dwindle = {
    -- 0 = split sigue al mouse
    -- 1 = siempre split a la izquierda/arriba
    -- 2 = siempre split a la derecha/abajo
    force_split = 0,

    -- Congela la dirección del split una vez establecida
    -- Sin esto, cambiar resolución reorganiza todo el árbol
    preserve_split = true,

    -- Divide el contenedor en 4 triángulos virtuales
    -- El triángulo donde está el cursor determina la dirección
    -- Activa preserve_split implícitamente
    smart_split = false,

    -- El resize sigue la esquina más cercana al cursor
    smart_resizing = true,

    -- Factor de escala para ventanas en special workspace (scratchpad)
    -- 1.0 = mismo tamaño, 0.8 = 80% del espacio
    special_scale_factor = 0.8,

    -- Multiplicador de ancho para el auto-split
    -- Útil en monitores ultrawide donde W >> H tras varios splits
    split_width_multiplier = 1.0,

    -- Usa la ventana activa (no el cursor) para decidir dónde split
    use_active_for_splits = true,

    -- Ratio inicial del split. 1.0 = 50/50
    default_split_ratio = 1.0,

    -- 0 = el split ratio se aplica al nodo direccional (izquierda/arriba)
    -- 1 = se aplica a la ventana actual
    split_bias = 0,

    -- Drop más preciso al mover ventanas con el mouse
    precise_mouse_move = false,
  },
})
