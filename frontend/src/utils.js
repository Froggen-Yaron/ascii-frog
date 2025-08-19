export function randomColor(text) {
    const colors = ['crimson', 'royalblue', 'forestgreen', 'gold', 'mediumpurple', 'hotpink', 'darkorange', 'teal', 'coral', 'limegreen'];
    const color = colors[Math.random() * colors.length | 0];
    const span = document.createElement('span');
    span.style.color = color;
    span.textContent = text;
    return span;
}
