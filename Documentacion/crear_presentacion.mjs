import fs from "node:fs/promises";
import path from "node:path";
import { pathToFileURL } from "node:url";
import { Presentation, PresentationFile } from "@oai/artifact-tool";

const workspaceDir = "C:/Users/elvis/OneDrive/Documentos/Proyecto-Elvy";
const SKILL_DIR = "C:/Users/elvis/.codex/plugins/cache/openai-primary-runtime/presentations/26.1007.11041/skills/presentations";
const RUNTIME_PYTHON = "C:/Users/elvis/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe";
const buildDir = path.join(workspaceDir, ".pptx-build");
const outputDir = path.join(workspaceDir, "Entrega");
const FINAL_PPTX = path.join(outputDir, "Exposicion-Computacion-Paralela-Elvy-1222572.pptx");
await fs.mkdir(buildDir, { recursive: true });
await fs.mkdir(outputDir, { recursive: true });

const deck = Presentation.create({ slideSize: { width: 1280, height: 720 } });
const C = { navy: "#15295B", blue: "#3C5CCF", cyan: "#21A7B8", gold: "#F0B44D", ink: "#172033", muted: "#5B6475", pale: "#F4F7FC", white: "#FFFFFF", line: "#D7DDEA", green: "#2FA36B" };
const font = "Aptos";

function box(slide, left, top, width, height, fill, radius="roundRect") {
  return slide.shapes.add({ geometry: radius, position: { left, top, width, height }, fill, line: { fill: "none", width: 0 } });
}
function text(slide, value, left, top, width, height, size=24, color=C.ink, bold=false, align="left") {
  const s = slide.shapes.add({ geometry: "textbox", position: { left, top, width, height }, fill: "none", line: { fill: "none", width: 0 } });
  s.text = value;
  s.text.style = { fontFamily: font, fontSize: size, color, bold, textAlign: align, verticalAlignment: "middle" };
  return s;
}
function base(title, number) {
  const slide = deck.slides.add();
  slide.background.fill = C.pale;
  box(slide, 0, 0, 18, 720, C.blue, "rect");
  text(slide, title, 66, 44, 1050, 58, 34, C.navy, true);
  text(slide, String(number).padStart(2, "0"), 1155, 48, 60, 36, 16, C.blue, true, "right");
  box(slide, 66, 112, 1148, 2, C.line, "rect");
  return slide;
}
function bulletList(slide, items, left=80, top=150, width=540, size=23, gap=72) {
  items.forEach((item, i) => {
    box(slide, left, top + i*gap + 12, 12, 12, i % 2 ? C.cyan : C.blue, "ellipse");
    text(slide, item, left + 26, top + i*gap, width - 26, 55, size, C.ink, false);
  });
}
function concept(slide, label, desc, x, y, w, accent=C.blue) {
  box(slide, x, y, w, 150, C.white);
  box(slide, x, y, 8, 150, accent, "rect");
  text(slide, label, x+24, y+18, w-42, 36, 22, accent, true);
  text(slide, desc, x+24, y+58, w-42, 74, 18, C.muted, false);
}

// 1 Cover
{
  const s = deck.slides.add(); s.background.fill = C.navy;
  box(s, 760, -80, 600, 600, C.blue, "ellipse");
  box(s, 935, 350, 260, 260, C.cyan, "ellipse");
  text(s, "Computación paralela\ny plataformas cloud", 80, 130, 760, 190, 50, C.white, true);
  text(s, "Investigación, actividad práctica y caso UserFlow", 84, 345, 660, 55, 24, "#DCE5FF");
  box(s, 84, 435, 410, 3, C.gold, "rect");
  text(s, "ELVY ANTONIO GRULLÓN MOREL", 84, 466, 620, 36, 19, C.white, true);
  text(s, "Matrícula 1222572", 84, 505, 400, 30, 18, "#DCE5FF");
}

// 2 map
{
  const s = base("Mapa de la exposición", 2);
  concept(s,"Algoritmos","Árboles, Pointer Jumping, divide y vencerás y particionamiento.",70,150,350,C.blue);
  concept(s,"Ejecución","Pipelining, aceleramiento en cascada y sistema operativo.",465,150,350,C.cyan);
  concept(s,"Coordinación","Symmetry Breaking, cluster, balanceo y procesadores de tareas.",860,150,350,C.gold);
  concept(s,"Plataforma","Nexus, repositorios de imágenes, Pub/Sub y GitHub Actions.",265,360,750,C.green);
  text(s,"Pregunta guía: ¿cómo repartimos, coordinamos y desplegamos trabajo sin perder control?",150,570,980,55,24,C.navy,true,"center");
}

// 3 balanced + pointer
{
  const s=base("Estructuras que reducen recorridos",3);
  text(s,"Árbol balanceado",90,145,450,40,26,C.blue,true);
  const nodes=[[300,205,"8"],[205,295,"4"],[395,295,"12"],[155,390,"2"],[255,390,"6"],[345,390,"10"],[445,390,"14"]];
  nodes.forEach(([x,y,v])=>{box(s,x,y,58,58,C.white,"ellipse");text(s,v,x,y+5,58,42,20,C.navy,true,"center");});
  text(s,"Altura controlada: búsqueda O(log n)",110,490,470,48,20,C.muted,false,"center");
  text(s,"Pointer Jumping",690,145,420,40,26,C.cyan,true);
  ["A","B","C","D"].forEach((v,i)=>{box(s,700+i*125,250,64,64,i===3?C.cyan:C.white,"ellipse");text(s,v,700+i*125,260,64,40,20,i===3?C.white:C.navy,true,"center");});
  text(s,"Cada ronda duplica la distancia del salto",680,350,510,50,21,C.muted,false,"center");
  text(s,"Aplicación: índices, jerarquías y búsqueda de raíces",660,445,550,55,22,C.navy,true,"center");
}

// 4 divide partition
{
  const s=base("Dividir el problema y repartir el trabajo",4);
  text(s,"Problema",80,168,180,42,23,C.navy,true,"center");
  box(s,95,220,150,70,C.blue); text(s,"10 archivos",95,232,150,44,22,C.white,true,"center");
  for(let i=0;i<3;i++){box(s,340+i*235,210,175,90,i===1?C.cyan:C.white);text(s,["Grupo A","Grupo B","Grupo C"][i],340+i*235,225,175,55,21,i===1?C.white:C.navy,true,"center");}
  box(s,1045,220,150,70,C.green);text(s,"Resultados",1045,232,150,44,21,C.white,true,"center");
  concept(s,"Divide y vencerás","Resuelve subproblemas independientes y combina sus respuestas.",105,400,485,C.blue);
  concept(s,"Particionamiento","Distribuye datos por bloques, rangos, ciclos o hash.",680,400,485,C.cyan);
  text(s,"Riesgo común: una partición muy pesada deja recursos esperando",190,590,900,44,21,C.muted,true,"center");
}

// 5 pipeline cascade
{
  const s=base("Pipelining y aceleramiento en cascada",5);
  const stages=["Código","Pruebas","Docker","Terraform","Cloud Run"];
  stages.forEach((v,i)=>{box(s,65+i*238,190,190,82,i===4?C.green:(i%2?C.cyan:C.blue));text(s,v,65+i*238,210,190,42,20,C.white,true,"center");});
  text(s,"El pipeline solapa y ordena etapas. La etapa más lenta limita el ritmo.",130,315,1020,52,23,C.navy,true,"center");
  concept(s,"Cascada de mejoras","Algoritmo, concurrencia, caché, red y escalado pueden reforzarse.",130,420,480,C.gold);
  concept(s,"Límite real","La parte secuencial y la coordinación reducen el aceleramiento ideal.",670,420,480,C.blue);
}

// 6 symmetry
{
  const s=base("Symmetry Breaking evita decisiones idénticas",6);
  text(s,"Sin diferencia",90,160,430,40,25,C.navy,true,"center");
  [0,1,2].forEach(i=>{box(s,130+i*125,235,72,72,C.white,"ellipse");text(s,"?",130+i*125,248,72,40,25,C.blue,true,"center");});
  text(s,"Todos intentan usar el mismo recurso",90,340,430,45,20,C.muted,false,"center");
  text(s,"Con identificador o prioridad",690,160,470,40,25,C.navy,true,"center");
  ["1","2","3"].forEach((v,i)=>{box(s,735+i*125,235,72,72,i===0?C.green:C.white,"ellipse");text(s,v,735+i*125,248,72,40,24,i===0?C.white:C.navy,true,"center");});
  text(s,"Un participante obtiene el turno",690,340,470,45,20,C.muted,false,"center");
  text(s,"Ejemplos: elección de líder, bloqueos, IDs únicos y prioridades",160,485,960,60,24,C.blue,true,"center");
}

// 7 cluster load OS
{
  const s=base("Cluster, balanceo y sistema operativo",7);
  box(s,80,175,210,86,C.navy);text(s,"Solicitudes",80,195,210,44,22,C.white,true,"center");
  box(s,410,175,250,86,C.blue);text(s,"Balanceador",410,195,250,44,22,C.white,true,"center");
  [0,1,2].forEach(i=>{box(s,835,135+i*125,260,76,i===1?C.cyan:C.white);text(s,`Instancia ${i+1}`,835,151+i*125,260,44,21,i===1?C.white:C.navy,true,"center");});
  concept(s,"Cluster","Varios nodos entregan capacidad y tolerancia a fallos.",100,430,325,C.blue);
  concept(s,"Balanceo","Envía tráfico solo a instancias saludables.",475,430,325,C.cyan);
  concept(s,"Sistema operativo","Planifica procesos, hilos, memoria y dispositivos.",850,430,325,C.gold);
}

// 8 task processor pubsub
{
  const s=base("Procesadores de tareas y Pub/Sub",8);
  const labels=["API publica","Tema","Suscripción","Trabajador"];
  labels.forEach((v,i)=>{box(s,70+i*295,205,220,82,i===3?C.green:(i===1?C.cyan:C.blue));text(s,v,70+i*295,225,220,42,21,C.white,true,"center");});
  text(s,"El productor no necesita conocer al consumidor",140,330,1000,48,23,C.navy,true,"center");
  bulletList(s,["La cola absorbe picos de trabajo.","El consumidor confirma o reintenta mensajes.","Los trabajos deben tolerar duplicados."],220,425,850,20,60);
  text(s,"Extensión de UserFlow: ArchivoSubido activa auditoría o miniaturas",150,610,980,40,20,C.blue,true,"center");
}

// 9 repos
{
  const s=base("Nexus y repositorios de imágenes",9);
  concept(s,"Nexus Repository","Centraliza paquetes, dependencias y artefactos con permisos y versiones.",90,170,500,C.blue);
  concept(s,"Artifact Registry","Conserva la imagen OCI/Docker que Cloud Run ejecuta.",690,170,500,C.cyan);
  text(s,"Dockerfile",90,395,190,42,21,C.navy,true,"center");
  box(s,305,385,210,65,C.blue);text(s,"Cloud Build",305,396,210,40,20,C.white,true,"center");
  box(s,540,385,260,65,C.cyan);text(s,"Artifact Registry",540,396,260,40,20,C.white,true,"center");
  box(s,825,385,210,65,C.green);text(s,"Cloud Run",825,396,210,40,20,C.white,true,"center");
  text(s,"Las etiquetas facilitan uso; el digest identifica una versión inmutable",160,520,960,60,22,C.muted,true,"center");
}

//10 Actions
{
  const s=base("GitHub Actions automatiza la entrega",10);
  const steps=["Push a main","Build y test","Cloud Build","Terraform apply","Deploy"];
  steps.forEach((v,i)=>{box(s,60+i*242,190,190,86,i===4?C.green:(i%2?C.cyan:C.blue));text(s,v,60+i*242,210,190,46,19,C.white,true,"center");});
  concept(s,"Seguridad","Workload Identity Federation entrega credenciales temporales.",120,390,480,C.blue);
  concept(s,"Evidencia","Una ejecución verde demuestra un proceso reproducible.",680,390,480,C.green);
  text(s,"Secretos: GCP_PROJECT_ID · GCP_REGION · JWT_SECRET",160,585,960,38,20,C.muted,true,"center");
}

//11 architecture
{
  const s=base("Arquitectura serverless de UserFlow",11);
  const items=[[55,"Flutter",C.navy],[300,"API Gateway",C.blue],[565,"Cloud Run",C.cyan],[830,"Cloud SQL",C.green]];
  items.forEach(([x,v,c])=>{box(s,x,210,210,90,c);text(s,v,x,232,210,44,21,C.white,true,"center");});
  box(s,1075,210,150,90,C.gold);text(s,"Storage",1075,232,150,44,20,C.white,true,"center");
  bulletList(s,["JWT identifica al usuario en endpoints protegidos.","Secret Manager inyecta credenciales en ejecución.","Cloud Logging centraliza eventos del contenedor."],190,390,920,21,65);
}

//12 concurrent
{
  const s=base("Concurrencia en Flutter",12);
  text(s,"Secuencial",80,150,430,40,25,C.navy,true,"center");
  ["A","B","C"].forEach((v,i)=>{box(s,105+i*130,235,95,65,C.white);text(s,v,105+i*130,247,95,40,21,C.navy,true,"center");});
  text(s,"Cada tarea espera la anterior",90,330,410,42,20,C.muted,false,"center");
  text(s,"Concurrente con Future.wait",700,150,470,40,25,C.navy,true,"center");
  ["A","B","C"].forEach((v,i)=>{box(s,755+i*130,235,95,65,i===1?C.cyan:C.blue);text(s,v,755+i*130,247,95,40,21,C.white,true,"center");});
  text(s,"Las tareas independientes progresan juntas",700,330,470,42,20,C.muted,false,"center");
  text(s,"Medición: tiempo inicial, tiempo final y porcentaje de mejora",160,475,960,55,24,C.blue,true,"center");
  text(s,"La red y el servidor pueden limitar el resultado",210,555,860,44,20,C.muted,false,"center");
}

//13 demo
{
  const s=base("Demostración en clase",13);
  bulletList(s,["1. Abrir la ejecución verde de GitHub Actions.","2. Mostrar Cloud Run, API Gateway, Cloud SQL y Artifact Registry.","3. Ejecutar Flutter e iniciar sesión.","4. Crear, editar y eliminar un usuario.","5. Subir archivos y comparar modos secuencial y concurrente."],120,145,1040,22,78);
  box(s,210,575,860,62,C.navy);text(s,"URL: userflow-gateway-dy9hl9mi.uc.gateway.dev",210,586,860,40,19,C.white,true,"center");
}

//14 close
{
  const s=base("Ideas principales",14);
  concept(s,"Repartir","Divide y vencerás y particionamiento distribuyen el trabajo.",90,165,500,C.blue);
  concept(s,"Coordinar","Symmetry Breaking, colas y balanceo evitan conflictos.",690,165,500,C.cyan);
  concept(s,"Automatizar","Repositorios y Actions vuelven reproducible el despliegue.",90,380,500,C.gold);
  concept(s,"Medir","El tiempo observado confirma si la concurrencia aporta mejora.",690,380,500,C.green);
  text(s,"Preguntas",470,600,340,50,30,C.navy,true,"center");
}

// Render previews
for (const [i, slide] of deck.slides.items.entries()) {
  const png = await deck.export({ slide, format: "png", scale: 1 });
  await fs.writeFile(path.join(buildDir, `slide-${String(i+1).padStart(2,"0")}.png`), new Uint8Array(await png.arrayBuffer()));
}
const montage = await deck.export({ format: "webp", montage: true });
await fs.writeFile(path.join(buildDir, "montage.webp"), new Uint8Array(await montage.arrayBuffer()));

const { finalizePresentation } = await import(pathToFileURL(path.join(SKILL_DIR, "container_tools/artifact_tool_utils.mjs")).href);
const candidatePath = path.join(buildDir, "candidate.pptx");
await (await PresentationFile.exportPptx(deck)).save(candidatePath);
await finalizePresentation({
  workspaceDir,
  candidatePath,
  finalPath: FINAL_PPTX,
  pythonExecutable: RUNTIME_PYTHON,
  integrityValidatorPath: path.join(SKILL_DIR, "container_tools/inspect_presentation_package_integrity.py"),
  layoutValidatorPath: path.join(SKILL_DIR, "container_tools/inspect_presentation_layout_geometry.py"),
  layoutArgs: ["--expected-slide-size-emu", "12192000,6858000", "--validate-heading-fit"],
  requiredNativeTableOwnerSlides: [],
  requiredNativeChartOwnerSlides: [],
  fontPolicy: { basis: "design", families: [font] },
  verifyArtifactToolImport: true,
  receiptPath: path.join(buildDir, "presentation.validation.json"),
});
console.log(FINAL_PPTX);
