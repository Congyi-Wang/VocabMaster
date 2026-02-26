"""
Main window for VocabMaster Desktop.
"""
from PyQt6.QtWidgets import (
    QMainWindow, QWidget, QVBoxLayout, QHBoxLayout, QTabWidget,
    QPushButton, QLabel, QFileDialog, QTextEdit, QProgressBar,
    QComboBox, QSpinBox, QGroupBox, QMessageBox, QTableWidget,
    QTableWidgetItem, QHeaderView, QStatusBar,
)
from PyQt6.QtCore import Qt, QThread, pyqtSignal
from PyQt6.QtGui import QFont

from core.vocabulary_processor import (
    parse_vocabulary_file, divide_into_batches,
    save_vocabulary_json, load_vocabulary_json, merge_batches,
)
from core.claude_integration import process_all_batches
from core.theme_builder import build_theme_zip, list_themes, BUILT_IN_THEMES


class ClaudeWorker(QThread):
    """Background thread for Claude processing."""
    progress = pyqtSignal(int, int)  # current, total
    finished = pyqtSignal(list)
    error = pyqtSignal(str)

    def __init__(self, batches):
        super().__init__()
        self.batches = batches

    def run(self):
        try:
            results = process_all_batches(
                self.batches,
                progress_callback=lambda cur, tot: self.progress.emit(cur, tot),
            )
            self.finished.emit(results)
        except Exception as e:
            self.error.emit(str(e))


class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("VocabMaster - Vocabulary Processor")
        self.setMinimumSize(900, 650)
        self.vocabulary = []
        self.processed_vocabulary = []
        self.worker = None

        self._setup_ui()

    def _setup_ui(self):
        central = QWidget()
        self.setCentralWidget(central)
        layout = QVBoxLayout(central)

        # Title
        title = QLabel("VocabMaster")
        title.setFont(QFont("Segoe UI", 20, QFont.Weight.Bold))
        title.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(title)

        # Tabs
        tabs = QTabWidget()
        tabs.addTab(self._create_import_tab(), "1. Import")
        tabs.addTab(self._create_process_tab(), "2. Claude Check")
        tabs.addTab(self._create_export_tab(), "3. Export & Theme")
        layout.addWidget(tabs)

        # Status bar
        self.statusBar().showMessage("Ready")

    def _create_import_tab(self):
        widget = QWidget()
        layout = QVBoxLayout(widget)

        # Import controls
        import_group = QGroupBox("Import Vocabulary")
        import_layout = QVBoxLayout(import_group)

        btn_row = QHBoxLayout()
        self.btn_import_txt = QPushButton("Import TXT File")
        self.btn_import_txt.clicked.connect(self._import_txt)
        btn_row.addWidget(self.btn_import_txt)

        self.btn_import_json = QPushButton("Import JSON File")
        self.btn_import_json.clicked.connect(self._import_json)
        btn_row.addWidget(self.btn_import_json)
        import_layout.addLayout(btn_row)

        self.lbl_import_status = QLabel("No file loaded")
        import_layout.addWidget(self.lbl_import_status)
        layout.addWidget(import_group)

        # Preview table
        preview_group = QGroupBox("Vocabulary Preview")
        preview_layout = QVBoxLayout(preview_group)

        self.table_preview = QTableWidget()
        self.table_preview.setColumnCount(2)
        self.table_preview.setHorizontalHeaderLabels(["Word", "Meaning"])
        self.table_preview.horizontalHeader().setSectionResizeMode(QHeaderView.ResizeMode.Stretch)
        preview_layout.addWidget(self.table_preview)
        layout.addWidget(preview_group)

        return widget

    def _create_process_tab(self):
        widget = QWidget()
        layout = QVBoxLayout(widget)

        # Settings
        settings_group = QGroupBox("Processing Settings")
        settings_layout = QHBoxLayout(settings_group)

        settings_layout.addWidget(QLabel("Batch size:"))
        self.spin_batch = QSpinBox()
        self.spin_batch.setRange(5, 50)
        self.spin_batch.setValue(15)
        settings_layout.addWidget(self.spin_batch)
        settings_layout.addStretch()
        layout.addWidget(settings_group)

        # Process button
        self.btn_process = QPushButton("Send to Claude for Checking")
        self.btn_process.setMinimumHeight(40)
        self.btn_process.clicked.connect(self._start_processing)
        layout.addWidget(self.btn_process)

        # Progress
        self.progress_bar = QProgressBar()
        layout.addWidget(self.progress_bar)
        self.lbl_progress = QLabel("")
        layout.addWidget(self.lbl_progress)

        # Log
        self.txt_log = QTextEdit()
        self.txt_log.setReadOnly(True)
        self.txt_log.setMaximumHeight(150)
        layout.addWidget(self.txt_log)

        # Result table
        result_group = QGroupBox("Processed Vocabulary")
        result_layout = QVBoxLayout(result_group)
        self.table_result = QTableWidget()
        self.table_result.setColumnCount(4)
        self.table_result.setHorizontalHeaderLabels(["Word", "Pronunciation", "Meaning", "Example Sentence"])
        self.table_result.horizontalHeader().setSectionResizeMode(QHeaderView.ResizeMode.Stretch)
        result_layout.addWidget(self.table_result)
        layout.addWidget(result_group)

        return widget

    def _create_export_tab(self):
        widget = QWidget()
        layout = QVBoxLayout(widget)

        # Save JSON
        save_group = QGroupBox("Save Processed Vocabulary")
        save_layout = QHBoxLayout(save_group)
        self.btn_save_json = QPushButton("Save as JSON")
        self.btn_save_json.clicked.connect(self._save_json)
        save_layout.addWidget(self.btn_save_json)
        self.btn_save_txt = QPushButton("Save as TXT")
        self.btn_save_txt.clicked.connect(self._save_txt)
        save_layout.addWidget(self.btn_save_txt)
        layout.addWidget(save_group)

        # Theme builder
        theme_group = QGroupBox("Build Themed Package (.zip)")
        theme_layout = QVBoxLayout(theme_group)

        theme_row = QHBoxLayout()
        theme_row.addWidget(QLabel("Theme:"))
        self.combo_theme = QComboBox()
        themes = list_themes()
        for key, desc in themes.items():
            self.combo_theme.addItem(desc, key)
        theme_row.addWidget(self.combo_theme)
        theme_layout.addLayout(theme_row)

        # Theme preview
        self.lbl_theme_preview = QLabel("")
        self.lbl_theme_preview.setWordWrap(True)
        theme_layout.addWidget(self.lbl_theme_preview)
        self.combo_theme.currentIndexChanged.connect(self._update_theme_preview)
        self._update_theme_preview()

        self.btn_build_zip = QPushButton("Build Theme ZIP")
        self.btn_build_zip.setMinimumHeight(40)
        self.btn_build_zip.clicked.connect(self._build_zip)
        theme_layout.addWidget(self.btn_build_zip)

        layout.addWidget(theme_group)
        layout.addStretch()

        return widget

    # --- Actions ---

    def _import_txt(self):
        path, _ = QFileDialog.getOpenFileName(self, "Open Vocabulary TXT", "", "Text Files (*.txt);;All Files (*)")
        if not path:
            return
        try:
            self.vocabulary = parse_vocabulary_file(path)
            self._refresh_preview_table()
            self.lbl_import_status.setText(f"Loaded {len(self.vocabulary)} words from {path}")
            self.statusBar().showMessage(f"Imported {len(self.vocabulary)} words")
        except Exception as e:
            QMessageBox.critical(self, "Import Error", str(e))

    def _import_json(self):
        path, _ = QFileDialog.getOpenFileName(self, "Open Vocabulary JSON", "", "JSON Files (*.json);;All Files (*)")
        if not path:
            return
        try:
            self.vocabulary = load_vocabulary_json(path)
            self._refresh_preview_table()
            self.lbl_import_status.setText(f"Loaded {len(self.vocabulary)} words from {path}")
            self.statusBar().showMessage(f"Imported {len(self.vocabulary)} words")
        except Exception as e:
            QMessageBox.critical(self, "Import Error", str(e))

    def _refresh_preview_table(self):
        self.table_preview.setRowCount(len(self.vocabulary))
        for i, entry in enumerate(self.vocabulary):
            self.table_preview.setItem(i, 0, QTableWidgetItem(entry.get("word", "")))
            self.table_preview.setItem(i, 1, QTableWidgetItem(entry.get("meaning", "")))

    def _start_processing(self):
        if not self.vocabulary:
            QMessageBox.warning(self, "No Data", "Please import vocabulary first (Tab 1).")
            return

        batch_size = self.spin_batch.value()
        batches = divide_into_batches(self.vocabulary, batch_size)

        self.txt_log.clear()
        self.txt_log.append(f"Processing {len(self.vocabulary)} words in {len(batches)} batches...")
        self.progress_bar.setMaximum(len(batches))
        self.progress_bar.setValue(0)
        self.btn_process.setEnabled(False)

        self.worker = ClaudeWorker(batches)
        self.worker.progress.connect(self._on_progress)
        self.worker.finished.connect(self._on_finished)
        self.worker.error.connect(self._on_error)
        self.worker.start()

    def _on_progress(self, current, total):
        self.progress_bar.setValue(current)
        self.lbl_progress.setText(f"Batch {current}/{total}")
        self.txt_log.append(f"Batch {current}/{total} completed.")

    def _on_finished(self, results):
        self.processed_vocabulary = results
        self.btn_process.setEnabled(True)
        self.lbl_progress.setText(f"Done! {len(results)} words processed.")
        self.txt_log.append(f"All batches completed. {len(results)} words ready.")
        self.statusBar().showMessage("Processing complete!")

        # Fill result table
        self.table_result.setRowCount(len(results))
        for i, entry in enumerate(results):
            self.table_result.setItem(i, 0, QTableWidgetItem(entry.get("word", "")))
            self.table_result.setItem(i, 1, QTableWidgetItem(entry.get("pronunciation", "")))
            self.table_result.setItem(i, 2, QTableWidgetItem(entry.get("meaning", "")))
            self.table_result.setItem(i, 3, QTableWidgetItem(entry.get("example_sentence", "")))

    def _on_error(self, error_msg):
        self.btn_process.setEnabled(True)
        self.txt_log.append(f"ERROR: {error_msg}")
        QMessageBox.critical(self, "Processing Error", error_msg)

    def _save_json(self):
        data = self.processed_vocabulary or self.vocabulary
        if not data:
            QMessageBox.warning(self, "No Data", "No vocabulary to save.")
            return
        path, _ = QFileDialog.getSaveFileName(self, "Save JSON", "vocabulary.json", "JSON Files (*.json)")
        if path:
            save_vocabulary_json(data, path)
            self.statusBar().showMessage(f"Saved to {path}")

    def _save_txt(self):
        data = self.processed_vocabulary or self.vocabulary
        if not data:
            QMessageBox.warning(self, "No Data", "No vocabulary to save.")
            return
        path, _ = QFileDialog.getSaveFileName(self, "Save TXT", "vocabulary.txt", "Text Files (*.txt)")
        if path:
            with open(path, "w", encoding="utf-8") as f:
                for entry in data:
                    parts = [entry.get("word", "")]
                    if entry.get("pronunciation"):
                        parts.append(entry["pronunciation"])
                    if entry.get("meaning"):
                        parts.append(entry["meaning"])
                    if entry.get("example_sentence"):
                        parts.append(entry["example_sentence"])
                    f.write(" | ".join(parts) + "\n")
            self.statusBar().showMessage(f"Saved to {path}")

    def _update_theme_preview(self):
        key = self.combo_theme.currentData()
        if key and key in BUILT_IN_THEMES:
            theme = BUILT_IN_THEMES[key]
            colors = theme["colors"]
            self.lbl_theme_preview.setText(
                f"Style: {theme['style']}  |  Primary: {colors['primary']}  |  "
                f"Background: {colors['background']}  |  Accent: {colors['accent']}"
            )

    def _build_zip(self):
        data = self.processed_vocabulary or self.vocabulary
        if not data:
            QMessageBox.warning(self, "No Data", "No vocabulary to package. Import or process first.")
            return

        theme_key = self.combo_theme.currentData()
        default_name = f"vocabmaster_{theme_key}.zip"
        path, _ = QFileDialog.getSaveFileName(self, "Save Theme ZIP", default_name, "ZIP Files (*.zip)")
        if path:
            try:
                build_theme_zip(theme_key, data, path)
                self.statusBar().showMessage(f"Theme ZIP saved to {path}")
                QMessageBox.information(self, "Success", f"Theme package built!\n{path}")
            except Exception as e:
                QMessageBox.critical(self, "Build Error", str(e))
