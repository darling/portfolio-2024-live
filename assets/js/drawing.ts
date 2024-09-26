import { LazyBrush } from "lazy-brush";

type Point = {
  x: number;
  y: number;
}
type Points = Point[];
type Stroke = {
  points: Points,
  color: string,
  size: number
}

const getPointFromEvent = (e: PointerEvent | TouchEvent): Point => {
  let px = 0;
  let py = 0;

  // If there's multiple fingers, just use the first one
  if ('touches' in e) {
    px = e.touches[0].clientX;
    py = e.touches[0].clientY;
  } else {
    px = e.clientX;
    py = e.clientY;
  }

  // Normalize the coordinates to the canvas
  const canvas = e.target as HTMLCanvasElement;
  const rect = canvas.getBoundingClientRect();
  const scaleX = canvas.width / rect.width;
  const scaleY = canvas.height / rect.height;

  // Return the coordinates
  return {
    x: (px - rect.left) * scaleX,
    y: (py - rect.top) * scaleY
  };
};

const lazyRadius = 1;
const friction = 0.1;

export const createDrawingCanvas = (canvas: HTMLCanvasElement) => {
  const lazyBrush = new LazyBrush({
    radius: lazyRadius,
    enabled: true
  });

  let isDrawing = false;
  let points: Point[] = [];
  let x = 0;
  let y = 0;

  const handleStartEvent = (e: PointerEvent | TouchEvent) => {
    if ('touches' in e && e.touches.length > 1) {
      isDrawing = false;
      points = [];
      return;
    }

    e.preventDefault();

    isDrawing = true;

    const pos = getPointFromEvent(e);

    if (typeof TouchEvent !== 'undefined' && e instanceof TouchEvent) {
      lazyBrush.update(pos, { both: true });
    }

    x = pos.x;
    y = pos.y;
  };

  const handleMoveEvent = (e: PointerEvent | TouchEvent) => {
    if ('touches' in e && e.touches.length > 1) {
      isDrawing = false;
      points = [];
      return;
    }

    e.preventDefault();
    const pos = getPointFromEvent(e);
    x = pos.x;
    y = pos.y;
  };

  const handleFinishEvent = (e: PointerEvent | TouchEvent) => {
    e.preventDefault();
    isDrawing = false;
  };

  // Starting a new stroke
  canvas.addEventListener('pointerdown', handleStartEvent, { passive: false });
  canvas.addEventListener('touchstart', handleStartEvent, { passive: false });

  // Moving the stroke
  canvas.addEventListener('pointermove', handleMoveEvent, { passive: false });
  canvas.addEventListener('touchmove', handleMoveEvent, { passive: false });

  // Ending a stroke
  canvas.addEventListener('pointerup', handleFinishEvent, { passive: false });
  canvas.addEventListener('pointerleave', handleFinishEvent, { passive: false });
  canvas.addEventListener('pointercancel', handleFinishEvent, { passive: false });
  canvas.addEventListener('pointerout', handleFinishEvent, { passive: false });
  canvas.addEventListener('touchend', handleFinishEvent, { passive: false });
  canvas.addEventListener('touchcancel', handleFinishEvent, { passive: false });

  const destroy = () => {
    canvas.remove();
  };

  return {
    // Return the state to be used by Canvas
    lazyBrush,
    snapShotBrush: () => {
      lazyBrush.update({ x, y }, { friction });
    },

    isDrawing: () => isDrawing,
    getPoints: () => points,
    setPoints: (newPoints: Point[]) => {
      points = newPoints;
    },

    lazyRadius,
    friction,
    destroy
  };
};

const clearContext = (ctx: CanvasRenderingContext2D) => {
  ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);
};

const drawPointsOnCanvasAsCurve = (ctx: CanvasRenderingContext2D, points: Points) => {
  if (points.length < 2) return;

  let p1 = points[0];
  let p2 = points[1];

  ctx.imageSmoothingEnabled = true;
  ctx.imageSmoothingQuality = 'high';

  ctx.moveTo(p2.x, p2.y);
  ctx.beginPath();

  for (let i = 1, len = points.length; i < len; i++) {
    const midpoint = {
      x: p1.x + (p2.x - p1.x) / 2,
      y: p1.y + (p2.y - p1.y) / 2
    };
    ctx.quadraticCurveTo(p1.x, p1.y, midpoint.x, midpoint.y);
    p1 = points[i];
    p2 = points[i + 1];
  }

  ctx.lineTo(p1.x, p1.y);
  ctx.stroke();
  ctx.closePath();
};

/**
 * Add old strokes to set
 */
export const hydrateCanvas = (ctx: CanvasRenderingContext2D | null, strokes: Stroke[]) => {
  if (!ctx) return;
  clearContext(ctx);
  strokes.forEach((move) => {
    ctx.lineWidth = move.size * 2;
    ctx.strokeStyle = move.color;
    ctx.lineCap = 'round';
    ctx.lineJoin = 'round';

    drawPointsOnCanvasAsCurve(ctx, move.points);
  });
};

// Points have 1 / fidelity precision
const fidelity = 1000;

export const uniqueWithinTolerance = (a: Point, b: Point) => {
  const tolerance = 1 / fidelity;
  return Math.abs(a.x - b.x) < tolerance && Math.abs(a.y - b.y) < tolerance;
};
const perpendicularDistance = (pt: Point, lineStart: Point, lineEnd: Point): number => {
  const dx = lineEnd.x - lineStart.x;
  const dy = lineEnd.y - lineStart.y;

  // Normalize
  const len = Math.sqrt(dx * dx + dy * dy);
  const ddx = dx / len;
  const ddy = dy / len;

  const t = ddx * (pt.x - lineStart.x) + ddy * (pt.y - lineStart.y);

  const ex = t * ddx + lineStart.x;
  const ey = t * ddy + lineStart.y;

  return Math.sqrt((ex - pt.x) * (ex - pt.x) + (ey - pt.y) * (ey - pt.y));
};

export const ramerDouglasPeucker = (points: Point[], epsilon: number): Point[] => {
  let dmax = 0;
  let index = 0;
  const end = points.length - 1;

  for (let i = 1; i < end; i++) {
    const d = perpendicularDistance(points[i], points[0], points[end]);
    if (d > dmax) {
      index = i;
      dmax = d; // Update dmax here
    }
  }

  if (dmax > epsilon) {
    const recResults1 = ramerDouglasPeucker(points.slice(0, index + 1), epsilon);
    const recResults2 = ramerDouglasPeucker(points.slice(index, end + 1), epsilon);

    return [...recResults1, ...recResults2.slice(1)];
  } else {
    return [points[0], points[end]];
  }
};

export const tightenPoints = (p: Point[]): Point[] => {
  let o = p.map((point) => ({
    x: Math.round(point.x * 1000) / 1000,
    y: Math.round(point.y * 1000) / 1000
  }));
  // Only allow up to 1000 points
  o = o.slice(0, 1000);
  return o;
};
