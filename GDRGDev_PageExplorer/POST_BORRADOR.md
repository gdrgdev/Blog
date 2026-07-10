# 🗺️ Page Explorer para Business Central: campos, valores y acciones en una sola ventana

Existe una situación recurrente en el trabajo diario con Business Central: estás en un registro cualquiera y necesitas saber qué campos tiene esa página, qué valor tienen en ese momento, qué describe cada uno y qué acciones están disponibles.

Sí, está el Page Inspector nativo. Pero no muestra los tooltips de los campos, no te da el valor actual del registro de forma cómoda y no distingue qué acciones pertenecen a cada sección.

Por lo que la idea de esta extensión es diferente: un **Page Explorer** que se abre desde el propio registro y te muestra, en una sola ventana, todos los campos con su valor actual y descripción, y todas las acciones disponibles con su tooltip.

## ¿Cómo funciona?

La extensión usa dos fuentes de datos nativas de BC. Para los campos se apoya en el codeunit `Page Summary Provider`, que devuelve un JSON con el caption, valor y tooltip de cada campo del registro activo. Para las acciones consulta directamente la tabla del sistema `Page Action`, filtrando por `Page ID` y excluyendo acciones internas. A partir de ahí carga todo en una tabla temporal y lo muestra en dos partes lado a lado: **Fields** y **Actions**.

El botón **Page Explorer** aparece en la sección de procesamiento de cada página extendida. Al pulsarlo, pasa el ID de la página y el `SystemId` del registro actual, y se abre la ventana.

> 📸 **Imagen aquí**: captura del botón «Page Explorer» visible en la barra de procesamiento de la Customer Card, antes de abrirse la ventana.

Lo que ves en el Page Explorer:

• **Fields**: nombre del campo, valor actual en negrita si tiene valor, y descripción en rojo si el campo no tiene tooltip definido.
• **Actions**: nombre de la acción y su descripción. Las acciones promovidas se destacan visualmente.
• **With Value Only**: filtra y muestra únicamente los campos que tienen valor. Cambia a **Show All Fields** para volver a la vista completa.
• **View Page Summary JSON**: muestra el JSON devuelto por el `Page Summary Provider`, útil para depuración.
• **Summary**: nombre de la página, número de campos y número de acciones.

> 📸 **Imagen aquí**: captura de la ventana Page Explorer abierta sobre la Customer Card — se ven los dos ListParts (Fields y Actions) lado a lado, con algún campo en rojo por falta de tooltip y alguna acción promovida destacada.

## Un detalle técnico: `PageType = ListPlus`

Para conseguir los dos ListParts lado a lado, la clave está en combinar `PageType = ListPlus` con un grupo de tipo `FixedLayout`. Con `Card`, `Worksheet` o `Document` el compilador AL no permite usar `GroupType` cuando los hijos del grupo son `part`. Solo con `ListPlus` funciona.

```al
page 97817 "GDRGPE Page Explorer"
{
    PageType = ListPlus;

    layout
    {
        area(Content)
        {
            group(General)
            {
                ShowCaption = false;
                part(FieldsPart; "GDRGPE Fields Part") { Caption = 'Fields'; }
                part(ActionsPart; "GDRGPE Act Part")   { Caption = 'Actions'; }
            }
        }
    }
}
```

> 📸 **Imagen aquí**: captura del filtro «With Value Only» activo, mostrando solo los campos con valor — útil para ver el contraste con «Show All Fields».

## El Sales Order: cabecera y líneas

Un caso interesante es el Sales Order. Al tener cabecera y subform de líneas, podemos añadir el botón en los dos niveles de forma independiente. El botón en la cabecera abre el explorer con los campos del `Sales Header`; el botón en las líneas abre el explorer con los campos del `Sales Line` seleccionado en ese momento. Dos vistas completamente distintas, desde el mismo pedido.

> 📸 **Imagen aquí**: dos capturas en paralelo — el Page Explorer abierto desde la cabecera del Sales Order (campos de `Sales Header`) y desde una línea del subform (campos de `Sales Line`).

El código se encuentra aquí, por si quieres revisarlo: [pendiente enlace GitHub]

## Cómo extenderlo a cualquier página

El patrón es siempre el mismo: una `pageextension` que añade la acción en `processing` y pasa el `Page::` correspondiente junto al `SystemId` del registro.

```al
pageextension 97818 "GDRGPE Cust Card Ext" extends "Customer Card"
{
    actions
    {
        addlast(processing)
        {
            action(GDRGPEPageExplorer)
            {
                ApplicationArea = All;
                Caption = 'Page Explorer';
                Image = Info;
                ToolTip = 'Shows all fields and available actions on this page with their descriptions.';

                trigger OnAction()
                var
                    PageExplorerPage: Page "GDRGPE Page Explorer";
                begin
                    PageExplorerPage.SetParameters(Page::"Customer Card", Rec.SystemId);
                    PageExplorerPage.RunModal();
                end;
            }
        }
        addlast(Promoted)
        {
            actionref(GDRGPEPageExplorer_Promoted; GDRGPEPageExplorer) { }
        }
    }
}
```

Los dos únicos valores que cambian entre extensiones son la página base (`extends`) y el argumento `Page::` en `SetParameters`. El resto del patrón es idéntico.

> 📸 **Imagen aquí**: captura de la vista «View Page Summary JSON» — el JSON raw renderizado con resaltado de sintaxis dentro de BC.

La solución se compone de los siguientes objetos:

`GDRGPEGuideLine.Table.al`: Tabla temporal que almacena cada línea (campo o acción) con su caption, valor, tooltip, tipo y estilo.
`GDRGPEGuideBuilder.Codeunit.al`: Parsea el JSON del `Page Summary Provider` y rellena la tabla temporal.
`GDRGPEJSONRenderer.Codeunit.al`: Renderiza el JSON en HTML para la vista de depuración.
`GDRGPEPageExplorer.Page.al`: Ventana principal con los dos ListParts lado a lado.
`GDRGPEFieldsPart.Page.al`: ListPart de campos con filtro por valor.
`GDRGPEActPart.Page.al`: ListPart de acciones agrupadas por sección.
`GDRGPERawJSON.Page.al`: Visualizador del JSON raw con resaltado de sintaxis.
`GDRGPELineType.Enum.al`: Enum con los tipos de línea: Header, Field, Action.
`GDRGPECustCardExt.PageExt.al`: Botón en Customer Card.
`GDRGPEVendCardExt.PageExt.al`: Botón en Vendor Card.
`GDRGPEItemCardExt.PageExt.al`: Botón en Item Card.
`GDRGPESalesOrderExt.PageExt.al`: Botón en Sales Order (cabecera).
`GDRGPESalesOrderSubExt.PageExt.al`: Botón en Sales Order Subform (líneas).

De esta manera, la próxima vez que necesites entender qué tiene una página, no tienes que abrir documentación, buscar en el inspector ni recordar de memoria: lo tienes delante, en el registro que ya estás trabajando.

Espero que esta información te ayude.

Más información:

- [Page Summary Provider – Microsoft Learn](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-page-summary-provider)
- [PageType Property – Microsoft Learn](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/properties/devenv-pagetype-property)
- [GroupType Property – Microsoft Learn](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/properties/devenv-grouptype-property)
