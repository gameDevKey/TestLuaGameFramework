using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using UnityEditor;

namespace Tools
{
	public class ProgressIndicator : IDisposable
	{
		private string title;
		private int current;
		private int total;

		public ProgressIndicator(string title)
		{
			this.title = title;
		}

		public void AddProgress(int count = 1)
		{
			this.current += count;
		}

		public void SetTotal(int total)
		{
			this.total = total;
		}

		public bool Show(string message)
		{
			var progress = (float)this.current / (float)this.total;
			return EditorUtility.DisplayCancelableProgressBar(
				this.title, message, progress);
		}

		public bool Show(string format, params object[] args)
		{
			return this.Show(string.Format(format, args));
		}

		public void Dispose()
		{
			EditorUtility.ClearProgressBar();
		}
	}
}
